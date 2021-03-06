# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupGroupLink do
  let_it_be(:group) { create(:group) }
  let_it_be(:shared_group) { create(:group) }
  let_it_be(:group_group_link) do
    create(:group_group_link, shared_group: shared_group,
                              shared_with_group: group)
  end

  describe 'relations' do
    it { is_expected.to belong_to(:shared_group) }
    it { is_expected.to belong_to(:shared_with_group) }
  end

  describe 'scopes' do
    describe '.non_guests' do
      let!(:group_group_link_reporter) { create :group_group_link, :reporter }
      let!(:group_group_link_maintainer) { create :group_group_link, :maintainer }
      let!(:group_group_link_owner) { create :group_group_link, :owner }
      let!(:group_group_link_guest) { create :group_group_link, :guest }

      it 'returns all records which are greater than Guests access' do
        expect(described_class.non_guests).to match_array([
                                                           group_group_link_reporter, group_group_link,
                                                           group_group_link_maintainer, group_group_link_owner
                                                          ])
      end
    end
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:shared_group) }

    it do
      is_expected.to(
        validate_uniqueness_of(:shared_group_id)
          .scoped_to(:shared_with_group_id)
          .with_message('The group has already been shared with this group'))
    end

    it { is_expected.to validate_presence_of(:shared_with_group) }
    it { is_expected.to validate_presence_of(:group_access) }

    it do
      is_expected.to(
        validate_inclusion_of(:group_access).in_array(Gitlab::Access.values))
    end
  end

  describe '#human_access' do
    it 'delegates to Gitlab::Access' do
      expect(Gitlab::Access).to receive(:human_access).with(group_group_link.group_access)

      group_group_link.human_access
    end
  end
end
