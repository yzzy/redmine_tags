module RedmineTags
  module Patches
    module IssuesPdfHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method :fetch_row_values_without_redmine_tags, :fetch_row_values
          alias_method :fetch_row_values, :fetch_row_values_with_redmine_tags
        end
      end

      module InstanceMethods
        def fetch_row_values_with_redmine_tags(issue, query, level)
          query.inline_columns.collect do |column|
            s =
              if column.is_a?(QueryCustomFieldColumn)
                cv = issue.visible_custom_field_values.detect {|v| v.custom_field_id == column.custom_field.id}
                show_value(cv, false)
              else
                value = column.value_object(issue)
                case column.name
                when :subject
                  value = "  " * level + value
                when :attachments
                  value = value.to_a.map {|a| a.filename}.join("\n")
                when :tags
                  value = value.to_a.map(&:to_s).compact.join(',')
                end
                if value.is_a?(Date)
                  format_date(value)
                elsif value.is_a?(Time)
                  format_time(value)
                elsif value.is_a?(Float)
                  sprintf "%.2f", value
                else
                  value
                end
              end
            s.to_s
          end
        end
      end
    end
  end
end
