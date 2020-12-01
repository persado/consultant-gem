# frozen_string_literal: true

module Consultant
  module Utility
    class RecordCollection
      attr_accessor :records, :index, :record_fetcher

      def self.populate_with(record_type, number_of_runs, fetcher_info)
        record_fetcher = RecordFetcher.new(record_type, number_of_runs, fetcher_info)
        new(record_fetcher).populate!
      end

      def initialize(record_fetcher = nil)
        @records = []
        @index = 0
        @record_fetcher = record_fetcher
      end

      def populate!
        return unless record_fetcher.is_a?(RecordFetcher)

        self.records += record_fetcher.fetch
        raise 'could not find any matching records' if empty?

        self
      end

      def next
        return nil if empty?

        record = records[index % records.length]
        self.index += 1
        record
      end

      def empty?
        records.length.zero?
      end
    end
  end
end
