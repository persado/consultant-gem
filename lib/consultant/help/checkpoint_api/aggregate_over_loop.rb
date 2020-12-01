# frozen_string_literal: true

module Consultant
  module Help
    module CheckpointAPI
      module AggregateOverLoop
        include Help::APIEntry

        def self.description
          [
            "Used to aggregate a sub-block of code called",
            "during a larger iteration. Rather than wrapping the entire",
            "iteration, this method allows aggregations for",
            "a specific line or block of code WITHIN that iteration."
          ]
        end

        def self.usage_example
          [
            'array.each do |data|',
            '   call_service_a(data)',
            '   Checkpoint.aggregate_over_loop(',
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
