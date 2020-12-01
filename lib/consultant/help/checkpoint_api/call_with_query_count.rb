# frozen_string_literal: true

module Consultant
  module Help
    module CheckpointAPI
      module CallWithQueryCount
        include Help::APIEntry

        def self.description
          [
            'Counts and prints number of queries executed per wrapped block,',
            'alonside timing info.',
          ]
        end

        def self.usage_example
          [
            'Checkpoint.call_with_query_count(',
            '   output filename,',
            '   label,',
            ') do ',
            '   test code/wrapped code here...',
            'end',
          ]
        end
      end
    end
  end
end
