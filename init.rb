# frozen_string_literal: true

if Rails.try(:autoloaders).try(:zeitwerk_enabled?)
  RedmineTags::Hooks::ModelIssueHook
  RedmineTags::Hooks::ViewsIssuesHook
  RedmineTags::Hooks::ViewsWikiHook
else
  require 'redmine_tags'

  ActiveSupport::Reloader.to_prepare do
    paths = '/lib/redmine_tags/hooks/*_hook.rb'
    Dir.glob(File.dirname(__FILE__) + paths).each do |file|
      require_dependency file
    end
  end
end

[
  AutoCompletesController,
  Issue,
  IssueQuery,
  Project,
  QueriesHelper,
  WikiController,
  WikiPage,
  Redmine::Export::PDF::IssuesPdfHelper,
  Redmine::Views::ApiTemplateHandler
].each do |base|
  patch = "RedmineTags::Patches::#{base.name.split('::').last}Patch".constantize
  base.send(:include, patch) unless base.included_modules.include?(patch)
end

patch = RedmineTags::Patches::AddHelpersForIssueTagsPatch
[
  IssuesController,
  CalendarsController,
  GanttsController,
  SettingsController
].each do |base|
  base.send(:include, patch) unless base.included_modules.include?(patch)
end

Redmine::Plugin.register :redmine_tags do
  name        'Redmine Tags'
  author      'Aleksey V Zapparov AKA "ixti" & Alexander Abramov AKA "yzzy"'
  description 'Redmine tagging support'
  version     '5.0.2'
  url         'https://github.com/yzzy/redmine_tags/'
  author_url  'http://www.ixti.net/'

  requires_redmine version_or_higher: '4.0.0'

  settings \
    default:  {
      issues_sidebar:    'none',
      issues_show_count: 0,
      issues_open_only:  0,
      issues_sort_by:    'name',
      issues_sort_order: 'asc'
    },
    partial: 'tags/settings'
end
