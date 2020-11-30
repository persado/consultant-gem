# frozen_string_literal: true

module Consultant
  module Help
    module CheckpointAPI
      module AggregateOverLoopWithQueryCount
        include Help::CombinedFunctionality

        def self.composite_methods
          [:aggregate_over_loop, :call_with_query_count]
        end

        def self.usage_example
          [
            'array.each do |data|',
            '   call_service_a(data)',
            '   Checkpoint.aggregate_over_loop_with_query_count(',
            '     output filename,',
            '     label,',
            '     length of iteration',
            '   ) do ',
            '     call_service_b(data)',
            '   end',
            '   call_service_c(data)',
            'end',
          ]
        end
      end
    end
  end
end
