module RedmineTags
  module Patches
    module ApiTemplateHandlerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          class << self
            alias_method :call_without_redmine_tags, :call
            alias_method :call, :call_with_redmine_tags
          end
        end
      end

      module ClassMethods
        def call_with_redmine_tags(template, source = nil)
          ActionController::Base.view_paths.each do |path|
            begin
              lines = File.readlines("#{path}/#{template.virtual_path}_with_tags.api.rsb")
              template.instance_variable_set("@source",template.source.sub(lines.last, lines.join)) unless lines.empty?
            rescue Errno::ENOENT
            end
          end
          if Redmine::VERSION::MAJOR < 5
            call_without_redmine_tags(template)
          else
            call_without_redmine_tags(template, source)
          end
        end
      end
    end
  end
end
