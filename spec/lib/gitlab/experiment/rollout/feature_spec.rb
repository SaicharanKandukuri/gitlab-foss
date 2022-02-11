# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Experiment::Rollout::Feature, :experiment do
  subject { described_class.new.for(subject_experiment) }

  let(:subject_experiment) { experiment('namespaced/stub') }

  describe "#enabled?" do
    before do
      allow(Feature::Definition).to receive(:get).and_return('_instance_')
      allow(Gitlab).to receive(:dev_env_or_com?).and_return(true)
      allow(Feature).to receive(:get).and_return(double(state: :on))
    end

    it "is enabled when all criteria are met" do
      expect(subject).to be_enabled
    end

    it "isn't enabled if the feature definition doesn't exist" do
      expect(Feature::Definition).to receive(:get).with('namespaced_stub').and_return(nil)

      expect(subject).not_to be_enabled
    end

    it "isn't enabled if we're not in dev or dotcom environments" do
      expect(Gitlab).to receive(:dev_env_or_com?).and_return(false)

      expect(subject).not_to be_enabled
    end

    it "isn't enabled if the feature flag state is :off" do
      expect(Feature).to receive(:get).with('namespaced_stub').and_return(double(state: :off))

      expect(subject).not_to be_enabled
    end
  end

  describe "#execute_assignment" do
    before do
      allow(Feature).to receive(:enabled?).with('namespaced_stub', any_args).and_return(true)
    end

    it "uses the default value as specified in the yaml" do
      expect(Feature).to receive(:enabled?).with(
        'namespaced_stub',
        subject,
        type: :experiment,
        default_enabled: :yaml
      ).and_return(false)

      expect(subject.execute_assignment).to be_nil
    end

    it "returns an assigned name" do
      allow(subject).to receive(:behavior_names).and_return([:variant1, :variant2])

      expect(subject.execute_assignment).to eq(:variant2)
    end
  end

  describe "#flipper_id" do
    it "returns the expected flipper id if the experiment doesn't provide one" do
      subject.instance_variable_set(:@experiment, double(id: '__id__'))
      expect(subject.flipper_id).to eq('Experiment;__id__')
    end

    it "lets the experiment provide a flipper id so it can override the default" do
      allow(subject_experiment).to receive(:flipper_id).and_return('_my_overridden_id_')

      expect(subject.flipper_id).to eq('_my_overridden_id_')
    end
  end
end
