# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dropdown base', :js do
  include FilteredSearchHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user, name: 'administrator', username: 'root') }
  let_it_be(:issue) { create(:issue, project: project) }

  let(:filtered_search) { find('.filtered-search') }
  let(:js_dropdown_assignee) { '#js-dropdown-assignee' }
  let(:filter_dropdown) { find("#{js_dropdown_assignee} .filter-dropdown") }

  def dropdown_assignee_size
    filter_dropdown.all('.filter-dropdown-item').size
  end

  before do
    project.add_maintainer(user)
    sign_in(user)

    visit project_issues_path(project)
  end

  describe 'caching requests' do
    it 'caches requests after the first load' do
      input_filtered_search('assignee:=', submit: false, extra_space: false)
      initial_size = dropdown_assignee_size

      expect(initial_size).to be > 0

      new_user = create(:user)
      project.add_maintainer(new_user)
      find('.filtered-search-box .clear-search').click
      input_filtered_search('assignee:=', submit: false, extra_space: false)

      expect(dropdown_assignee_size).to eq(initial_size)
    end
  end
end
