# frozen_string_literal: true

module Consultant
  module Utility
    module AggregationTrackers
      class Base
        attr_reader :num_calls, :total_queries, :total_execution_time

        def initialize
          @num_calls = 0
          @total_execution_time = 0
          @total_queries = 0
        end

        def add(time, queries)
          @num_calls += 1
          @total_execution_time += time
          @total_queries += queries
        end

        def current_totals
          {
            time: total_execution_time,
            queries: total_queries,
          }
        end
      end
    end
  end
end
