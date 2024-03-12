module RedmineTags
  module Patches
    module ProjectPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def tags(options = {})
          Issue.available_tags options.merge(project: self)
        end
      end
    end
  end
end
