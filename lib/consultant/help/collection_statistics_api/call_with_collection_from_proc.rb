# frozen_string_literal: true

module Consultant
  module Help
    module CollectionStatisticsAPI
      module CallWithCollectionFromProc
        include Help::APIEntry

        def self.description
          [
            'Instead of fetching random records,',
            'this method will use the proc provided',
            'to generate a collection set. If the number',
            'of records returned is less than the specified',
            'number of runs, tests will be called with the same',
            'records multiple times.',
          ]
        end

        def self.usage_example
          [
            'CollectionStatistics.call_with_collection_from_proc(',
            '   output filename,',
            '   record type (ActiveRecord model),',
            '   number of runs,',
            '   fetch records proc',
            ') do ',
            '   test code here...',
            'end',
          ]
        end
      end
    end
  end
end
