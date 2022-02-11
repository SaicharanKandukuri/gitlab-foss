# frozen_string_literal: true

module Types
  class WorkItemType < BaseObject
    graphql_name 'WorkItem'

    authorize :read_issue

    field :description, GraphQL::Types::String, null: true,
          description: 'Description of the work item.'
    field :id, Types::GlobalIDType[::WorkItem], null: false,
          description: 'Global ID of the work item.'
    field :iid, GraphQL::Types::ID, null: false,
          description: 'Internal ID of the work item.'
    field :state, WorkItemStateEnum, null: false,
          description: 'State of the work item.'
    field :title, GraphQL::Types::String, null: false,
          description: 'Title of the work item.'
    field :work_item_type, Types::WorkItems::TypeType, null: false,
          description: 'Type assigned to the work item.'

    markdown_field :title_html, null: true
    markdown_field :description_html, null: true
  end
end
