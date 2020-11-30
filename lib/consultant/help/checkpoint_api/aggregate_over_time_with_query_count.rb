# frozen_string_literal: true

module Consultant
module Help
    module CheckpointAPI
      module AggregateOverTimeWithQueryCount
        include Help::CombinedFunctionality

        def self.composite_methods
          [:aggregate_over_time, :call_with_query_count]
        end

        def self.usage_example
          [
            'Checkpoint.aggregate_over_time_with_query_count(',
            '   output filename,',
            '   label,',
            '   time to stop aggregating (instance of DateTime)',
            ') do ',
            '   test code/wrapped code here...',
            'end',
          ]
        end
      end
    end
  end
end
