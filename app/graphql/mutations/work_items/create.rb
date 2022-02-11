# frozen_string_literal: true

module Mutations
  module WorkItems
    class Create < BaseMutation
      include Mutations::SpamProtection
      include FindsProject

      graphql_name 'WorkItemCreate'

      authorize :create_work_item

      argument :description, GraphQL::Types::String,
               required: false,
               description: copy_field_description(Types::WorkItemType, :description)
      argument :project_path, GraphQL::Types::ID,
               required: true,
               description: 'Full path of the project the work item is associated with.'
      argument :title, GraphQL::Types::String,
               required: true,
               description: copy_field_description(Types::WorkItemType, :title)
      argument :work_item_type_id, ::Types::GlobalIDType[::WorkItems::Type],
               required: true,
               description: 'Global ID of a work item type.'

      field :work_item, Types::WorkItemType,
            null: true,
            description: 'Created work item.'

      def resolve(project_path:, **attributes)
        project = authorized_find!(project_path)
        params = global_id_compatibility_params(attributes).merge(author_id: current_user.id)

        spam_params = ::Spam::SpamParams.new_from_request(request: context[:request])
        work_item = ::WorkItems::CreateService.new(project: project, current_user: current_user, params: params, spam_params: spam_params).execute

        check_spam_action_response!(work_item)

        {
          work_item: work_item.valid? ? work_item : nil,
          errors: errors_on_object(work_item)
        }
      end

      private

      def global_id_compatibility_params(params)
        # TODO: remove this line when the compatibility layer is removed
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        params[:work_item_type_id] = ::Types::GlobalIDType[::WorkItems::Type].coerce_isolated_input(params[:work_item_type_id]) if params[:work_item_type_id]
        params[:work_item_type_id] = params[:work_item_type_id]&.model_id

        params
      end
    end
  end
end
