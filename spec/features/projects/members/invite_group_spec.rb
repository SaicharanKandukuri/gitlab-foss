# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project > Members > Invite group', :js do
  include Select2Helper
  include ActionView::Helpers::DateHelper
  include Spec::Support::Helpers::Features::MembersHelpers
  include Spec::Support::Helpers::Features::InviteMembersModalHelper

  let_it_be(:maintainer) { create(:user) }

  using RSpec::Parameterized::TableSyntax

  where(:invite_members_group_modal_enabled, :expected_invite_group_selector) do
    true  | 'button[data-qa-selector="invite_a_group_button"]' # rubocop:disable QA/SelectorUsage
    false | '#invite-group-tab'
  end

  with_them do
    before do
      stub_feature_flags(invite_members_group_modal: invite_members_group_modal_enabled)
    end

    it 'displays either the invite group button or the form with tabs based on the feature flag' do
      project = create(:project, namespace: create(:group))

      project.add_maintainer(maintainer)
      sign_in(maintainer)

      visit project_project_members_path(project)

      expect(page).to have_selector(expected_invite_group_selector)
    end

    it 'does not display either the form or the button when visiting the page not signed in' do
      project = create(:project, namespace: create(:group))

      visit project_project_members_path(project)

      expect(page).not_to have_selector(expected_invite_group_selector)
    end
  end

  describe 'Share with group lock' do
    let(:invite_group_selector) { 'button[data-qa-selector="invite_a_group_button"]' } # rubocop:disable QA/SelectorUsage

    shared_examples 'the project can be shared with groups' do
      it 'the "Invite a group" button exists' do
        visit project_project_members_path(project)
        expect(page).to have_selector(invite_group_selector)
      end
    end

    shared_examples 'the project cannot be shared with groups' do
      it 'the "Invite a group" button does not exist' do
        visit project_project_members_path(project)
        expect(page).not_to have_selector(invite_group_selector)
      end
    end

    context 'for a project in a root group' do
      let!(:group_to_share_with) { create(:group) }
      let(:project) { create(:project, namespace: create(:group)) }

      before do
        project.add_maintainer(maintainer)
        group_to_share_with.add_guest(maintainer)
        sign_in(maintainer)
      end

      context 'when the group has "Share with group lock" disabled' do
        it_behaves_like 'the project can be shared with groups'

        it 'the project can be shared with another group when the feature flag invite_members_group_modal is disabled' do
          stub_feature_flags(invite_members_group_modal: false)

          visit project_project_members_path(project)

          expect(page).not_to have_link 'Groups'

          click_on 'invite-group-tab'

          select2 group_to_share_with.id, from: '#link_group_id'
          page.find('body').click
          find('.btn-confirm').click

          click_link 'Groups'

          expect(members_table).to have_content(group_to_share_with.name)
        end

        it 'the project can be shared with another group when the feature flag invite_members_group_modal is enabled' do
          stub_feature_flags(invite_members_group_modal: true)

          visit project_project_members_path(project)

          expect(page).not_to have_link 'Groups'

          invite_group(group_to_share_with.name)

          visit project_project_members_path(project)

          click_link 'Groups'

          expect(members_table).to have_content(group_to_share_with.name)
        end
      end

      context 'when the group has "Share with group lock" enabled' do
        before do
          project.namespace.update_column(:share_with_group_lock, true)
        end

        it_behaves_like 'the project cannot be shared with groups'
      end
    end

    context 'for a project in a subgroup' do
      let!(:group_to_share_with) { create(:group) }
      let(:root_group) { create(:group) }
      let(:subgroup) { create(:group, parent: root_group) }
      let(:project) { create(:project, namespace: subgroup) }

      before do
        project.add_maintainer(maintainer)
        sign_in(maintainer)
      end

      context 'when the root_group has "Share with group lock" disabled' do
        context 'when the subgroup has "Share with group lock" disabled' do
          it_behaves_like 'the project can be shared with groups'
        end

        context 'when the subgroup has "Share with group lock" enabled' do
          before do
            subgroup.update_column(:share_with_group_lock, true)
          end

          it_behaves_like 'the project cannot be shared with groups'
        end
      end

      context 'when the root_group has "Share with group lock" enabled' do
        before do
          root_group.update_column(:share_with_group_lock, true)
        end

        context 'when the subgroup has "Share with group lock" disabled (parent overridden)' do
          it_behaves_like 'the project can be shared with groups'
        end

        context 'when the subgroup has "Share with group lock" enabled' do
          before do
            subgroup.update_column(:share_with_group_lock, true)
          end

          it_behaves_like 'the project cannot be shared with groups'
        end
      end
    end
  end

  describe 'setting an expiration date for a group link' do
    let(:project) { create(:project) }
    let!(:group) { create(:group) }

    let_it_be(:expiration_date) { 5.days.from_now.to_date }

    around do |example|
      freeze_time { example.run }
    end

    def setup
      project.add_maintainer(maintainer)
      group.add_guest(maintainer)
      sign_in(maintainer)

      visit project_project_members_path(project)

      invite_group(group.name, role: 'Guest', expires_at: expiration_date)
    end

    it 'the group link shows the expiration time with a warning class' do
      setup
      click_link 'Groups'

      expect(page).to have_field('Expiration date', with: expiration_date)
    end
  end

  describe 'the groups dropdown' do
    let_it_be(:parent_group) { create(:group, :public) }
    let_it_be(:project_group) { create(:group, :public, parent: parent_group) }
    let_it_be(:public_sub_subgroup) { create(:group, :public, parent: project_group) }
    let_it_be(:public_sibbling_group) { create(:group, :public, parent: parent_group) }
    let_it_be(:private_sibbling_group) { create(:group, :private, parent: parent_group) }
    let_it_be(:private_membership_group) { create(:group, :private) }
    let_it_be(:public_membership_group) { create(:group, :public) }
    let_it_be(:project) { create(:project, group: project_group) }

    before do
      private_membership_group.add_guest(maintainer)
      public_membership_group.add_maintainer(maintainer)

      sign_in(maintainer)
    end

    context 'for a project in a nested group' do
      it 'does not show the groups inherited from projects' do
        project.add_maintainer(maintainer)
        public_sibbling_group.add_maintainer(maintainer)

        visit project_project_members_path(project)

        click_on 'Invite a group'
        click_on 'Select a group'
        wait_for_requests

        page.within('[data-testid="group-select-dropdown"]') do
          expect_to_have_group(public_membership_group)
          expect_to_have_group(public_sibbling_group)
          expect_to_have_group(private_membership_group)

          expect_not_to_have_group(public_sub_subgroup)
          expect_not_to_have_group(private_sibbling_group)
          expect_not_to_have_group(parent_group)
          expect_not_to_have_group(project_group)
        end
      end

      it 'does not show the ancestors or project group', :aggregate_failures do
        parent_group.add_maintainer(maintainer)

        visit project_project_members_path(project)

        click_on 'Invite a group'
        click_on 'Select a group'
        wait_for_requests

        page.within('[data-testid="group-select-dropdown"]') do
          expect_to_have_group(public_membership_group)
          expect_to_have_group(public_sibbling_group)
          expect_to_have_group(private_membership_group)
          expect_to_have_group(public_sub_subgroup)
          expect_to_have_group(private_sibbling_group)

          expect_not_to_have_group(parent_group)
          expect_not_to_have_group(project_group)
        end
      end

      context 'when invite_members_group_modal feature disabled' do
        let(:group_invite_dropdown) { find('#select2-results-2') }

        before do
          stub_feature_flags(invite_members_group_modal: false)
        end

        it 'does not show the groups inherited from projects', :aggregate_failures do
          project.add_maintainer(maintainer)
          public_sibbling_group.add_maintainer(maintainer)

          visit project_project_members_path(project)

          click_on 'Invite group'
          click_on 'Search for a group'
          wait_for_requests

          expect(group_invite_dropdown).to have_text(public_membership_group.full_path)
          expect(group_invite_dropdown).to have_text(public_sibbling_group.full_path)
          expect(group_invite_dropdown).to have_text(private_membership_group.full_path)
          expect(group_invite_dropdown).not_to have_text(public_sub_subgroup.full_path)
          expect(group_invite_dropdown).not_to have_text(private_sibbling_group.full_path)
          expect(group_invite_dropdown).not_to have_text(parent_group.full_path, exact: true)
          expect(group_invite_dropdown).not_to have_text(project_group.full_path, exact: true)
        end

        it 'does not show the ancestors or project group', :aggregate_failures do
          parent_group.add_maintainer(maintainer)

          visit project_project_members_path(project)

          click_on 'Invite group'
          click_on 'Search for a group'
          wait_for_requests

          expect(group_invite_dropdown).to have_text(public_membership_group.full_path)
          expect(group_invite_dropdown).to have_text(public_sub_subgroup.full_path)
          expect(group_invite_dropdown).to have_text(public_sibbling_group.full_path)
          expect(group_invite_dropdown).to have_text(private_sibbling_group.full_path)
          expect(group_invite_dropdown).to have_text(private_membership_group.full_path)
          expect(group_invite_dropdown).not_to have_text(parent_group.full_path, exact: true)
          expect(group_invite_dropdown).not_to have_text(project_group.full_path, exact: true)
        end
      end

      def expect_to_have_group(group)
        expect(page).to have_selector("[entity-id='#{group.id}']")
      end

      def expect_not_to_have_group(group)
        expect(page).not_to have_selector("[entity-id='#{group.id}']")
      end
    end
  end
end
