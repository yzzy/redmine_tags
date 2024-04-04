require File.expand_path('../../test_helper', __FILE__)

class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects,
           :users, :email_addresses, :user_preferences,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :issue_relations,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :repositories,
           :changesets

  RedmineTags::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_tags).directory + '/test/fixtures/', [:taggings, :tags])

  include Redmine::I18n

  def setup
    User.current = nil
  end

  def response_hash
    response.parsed_body.is_a?(Hash) ? response.parsed_body : JSON.parse(response.body)
  end

  def test_show_project_should_not_display_tags_by_default_for_api_request
    get :show, params: { id: 1, format: :json }
    assert project = response_hash['project']
    assert_nil project['tags']
  end

  def test_show_project_should_not_display_tags_if_not_exists_for_api_request
    get :show, params: { id: 4, format: :json, include: 'tags' }
    assert tags = response_hash['project']['tags']
    assert_equal 0, tags.length
  end

  def test_show_project_should_display_tags_for_api_request
    get :show, params: { id: 1, format: :json, include: 'tags' }
    assert tags = response_hash['project']['tags']
    assert_equal 5, tags.length
  end

  def test_index_project_should_not_display_tags_by_default_for_api_request
    get :index, format: :json
    response_hash['projects'].each do |p|
      assert_nil p['tags']
    end
  end

  def test_index_project_should_display_own_tags_for_each_one_for_api_request
    get :index, params: { format: :json, include: 'tags' }
    assert projects = response_hash['projects']
    assert_equal 5, projects.detect{ |p| p["id"] == 1}['tags'].length
    assert_equal 0, projects.detect{ |p| p["id"] == 4}['tags'].length
    assert_equal 1, projects.detect{ |p| p["id"] == 3}['tags'].length
  end
end
