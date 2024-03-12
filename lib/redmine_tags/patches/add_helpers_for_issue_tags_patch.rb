module RedmineTags
  module Patches
    module AddHelpersForIssueTagsPatch
      def self.included(base)
        base.class_eval do
          helper IssuesTagsHelper
          helper TagsHelper
        end
      end
    end
  end
end
