# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProtectedBranches::CreateService do
  let(:project) { create(:project) }
  let(:user) { project.first_owner }
  let(:params) do
    {
      name: name,
      merge_access_levels_attributes: [{ access_level: Gitlab::Access::MAINTAINER }],
      push_access_levels_attributes: [{ access_level: Gitlab::Access::MAINTAINER }]
    }
  end

  describe '#execute' do
    let(:name) { 'master' }

    subject(:service) { described_class.new(project, user, params) }

    it 'creates a new protected branch' do
      expect { service.execute }.to change(ProtectedBranch, :count).by(1)
      expect(project.protected_branches.last.push_access_levels.map(&:access_level)).to eq([Gitlab::Access::MAINTAINER])
      expect(project.protected_branches.last.merge_access_levels.map(&:access_level)).to eq([Gitlab::Access::MAINTAINER])
    end

    context 'when protecting a branch with a name that contains HTML tags' do
      let(:name) { 'foo<b>bar<\b>' }

      subject(:service) { described_class.new(project, user, params) }

      it 'creates a new protected branch' do
        expect { service.execute }.to change(ProtectedBranch, :count).by(1)
        expect(project.protected_branches.last.name).to eq(name)
      end
    end

    context 'when user does not have permission' do
      let(:user) { create(:user) }

      before do
        project.add_developer(user)
      end

      it 'creates a new protected branch if we skip authorization step' do
        expect { service.execute(skip_authorization: true) }.to change(ProtectedBranch, :count).by(1)
      end

      it 'raises Gitlab::Access:AccessDeniedError' do
        expect { service.execute }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end

    context 'when a policy restricts rule creation' do
      before do
        policy = instance_double(ProtectedBranchPolicy, allowed?: false)
        expect(ProtectedBranchPolicy).to receive(:new).and_return(policy)
      end

      it "prevents creation of the protected branch rule" do
        expect do
          service.execute
        end.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end
  end
end
