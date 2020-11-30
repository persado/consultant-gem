# frozen_string_literal: true

module Consultant
  module Help
    module CollectionStatisticsAPI
      module CallWithCollectionFromPreviousRun
        include Help::APIEntry

        def self.description
          [
            'Instead of fetching random records,',
            'this method will load records from a previous run.',
            'It expects the filename of the previous run\'s output file.',
            'If the previous run has fewer entries than the number of runs',
            'specified, then the previous collection will be looped over,',
            'in order, until the test is complete.'
          ]
        end

        def self.usage_example
          [
            'CollectionStatistics.call_with_collection_from_previous_run(',
            '   output filename,',
            '   record type (ActiveRecord model),',
            '   number of runs,',
            '   output filename from previous run',
            ') do ',
            '   test code here...',
            'end',
          ]
        end
      end
    end
  end
end
