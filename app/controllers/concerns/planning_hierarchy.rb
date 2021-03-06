# frozen_string_literal: true

module PlanningHierarchy
  extend ActiveSupport::Concern

  # rubocop:disable Gitlab/ModuleWithInstanceVariables
  def planning_hierarchy
    return access_denied! unless can?(current_user, :read_planning_hierarchy, @project)

    return render_404 unless Feature.enabled?(:work_items_hierarchy, @project, default_enabled: :yaml)

    render 'shared/planning_hierarchy'
  end
  # rubocop:enable Gitlab/ModuleWithInstanceVariables
end

PlanningHierarchy.prepend_mod_with('PlanningHierarchy')
