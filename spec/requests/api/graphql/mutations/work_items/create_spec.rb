# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Create a work item' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user).tap { |user| project.add_developer(user) } }

  let(:input) do
    {
      'title' => 'new title',
      'description' => 'new description',
      'workItemTypeId' => WorkItems::Type.default_by_type(:task).to_global_id.to_s
    }
  end

  let(:mutation) { graphql_mutation(:workItemCreate, input.merge('projectPath' => project.full_path)) }

  let(:mutation_response) { graphql_mutation_response(:work_item_create) }

  context 'the user is not allowed to create a work item' do
    let(:current_user) { create(:user) }

    it_behaves_like 'a mutation that returns a top-level access error'
  end

  context 'when user has permissions to create a work item' do
    let(:current_user) { developer }

    it 'creates the work item' do
      expect do
        post_graphql_mutation(mutation, current_user: current_user)
      end.to change(WorkItem, :count).by(1)

      created_work_item = WorkItem.last

      expect(response).to have_gitlab_http_status(:success)
      expect(created_work_item.issue_type).to eq('task')
      expect(created_work_item.work_item_type.base_type).to eq('task')
      expect(mutation_response['workItem']).to include(
        input.except('workItemTypeId').merge(
          'id' => created_work_item.to_global_id.to_s,
          'workItemType' => hash_including('name' => 'Task')
        )
      )
    end

    it_behaves_like 'has spam protection' do
      let(:mutation_class) { ::Mutations::WorkItems::Create }
    end

    context 'when the work_items feature flag is disabled' do
      before do
        stub_feature_flags(work_items: false)
      end

      it_behaves_like 'a mutation that returns top-level errors',
        errors: ["Field 'workItemCreate' doesn't exist on type 'Mutation'", "Variable $workItemCreateInput is declared by anonymous mutation but not used"]
    end
  end
end
