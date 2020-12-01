# frozen_string_literal: true

module Consultant
  module Help
    module CollectionStatisticsAPI
      module Call
        include Help::APIEntry

        def self.description
          [
            'Basic call for CollectionStatistics.',
            'The service will fetch a random collection',
            'of records of the size and record type provided,',
            'and then run the test code on each record.',
            'The method accepts a hash as an optional fourth argument;',
            'if supplied, that hash will be used as a "where" clause',
            'to filter the collection.'
          ]
        end

        def self.usage_example
          [
            'CollectionStatistics.call(',
            '   output filename,',
            '   record type (ActiveRecord model),',
            '   number of runs',
            '   [ filter ]',
            ') do ',
            '   test code here...',
            'end',
          ]
        end
      end
    end
  end
end
