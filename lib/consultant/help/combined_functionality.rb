# frozen_string_literal: true

module Consultant
  module Help
    module CombinedFunctionality
      extend ActiveSupport::Concern
      include Help::APIEntry

      class_methods do
        def description
          "Combination of functionality from #{listify(composite_methods)}"
        end

        private

        def listify(array)
          return array.join(' and ') if array.size < 3
          array[-1] = "and " + array[-1]
          array.join(', ')
        end
      end
    end
  end
end