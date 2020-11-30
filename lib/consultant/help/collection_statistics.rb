# frozen_string_literal: true

module Consultant
  module Help
    module CollectionStatistics
      extend ActiveSupport::Concern
      include Help::Base

      class_methods do
        def description
          [
            'CollectionStatistics is used to run the same test '\
            'an arbitrary number of times on a record set.',
            'In addition to results for each test,'\
            'the output file provdes aggregate data for the record set:',
            'Average, Median, Min, Max and Total.',
            '',
            'This service should not be used in a live environment.',
            'The expectation is that it is used to run tests in a console.',
          ]
        end
      end
    end
  end
end
