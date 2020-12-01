# frozen_string_literal: true

module Consultant
  module Utility
    module AggregationTrackers
      class CollectionAggregationTracker < Base
        attr_reader :aggregation_length

        def initialize(aggregation_length)
          @aggregation_length = aggregation_length
          super()
        end

        def final?
          num_calls == aggregation_length
        end
      end
    end
  end
end