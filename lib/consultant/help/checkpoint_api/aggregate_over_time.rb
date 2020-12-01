# frozen_string_literal: true

module Consultant
  module Help
    module CheckpointAPI
      module AggregateOverTime
        include Help::APIEntry

        def self.description
          [
            'Used to aggregate all calls to a given block of code over',
            'a period of time. Useful in a live environment to get a sense',
            'of where time is spent in practice.',
          ]
        end

        def self.usage_example
          [
            'Checkpoint.aggregate_over_time(',
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
