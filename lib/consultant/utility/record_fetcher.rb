# frozen_string_literal: true

module Consultant
  module Utility
    class RecordFetcher
      include RecordFetcherHelpers
      attr_reader :record_type, :number_of_runs, :strategy_info

      def initialize(record_type, number_of_runs, strategy_info = nil)
        @record_type = record_type
        @number_of_runs = number_of_runs
        @strategy_info = strategy_info
      end

      [:filename, :fetcher_proc, :filter].each do |strategy_info_alias|
        alias_method strategy_info_alias, :strategy_info
      end

      def fetch
        case strategy_info.class.name
        when 'NilClass'
          default_fetch
        when 'String'
          fetch_from_file
        when 'Proc'
          fetch_with_proc
        when 'Hash'
          fetch_with_filter
        else
          raise "ERROR: invalid fetch strategy\n"\
          "#{CollectionStatistics.help(internal: true)}"
        end
      end

      def fetch_from_file
        ids = []
        File.open("tmp/#{filename}.txt", 'r') do |file|
          file.each_line do |line|
            id = parse_and_validate_input_file_line!(line)
            ids << id unless id.nil?
          end
        end
        if ids.uniq.length < number_of_runs
          records_hash = klass.where(id: ids).index_by(&:id)
          ids.map { |id| records_hash[id] }
        else
          klass.where(id: ids)
        end
      end

      def fetch_with_proc
        results = fetcher_proc.call
        ids =
          if results.respond_to?(:pluck)
            results.pluck(:id)
          elsif results.respond_to?(:id)
            [results.id]
          elsif results.respond_to?(:to_a) && results.to_a.first.respond_to?(:id)
            results.to_a.map(&:id)
          else
            raise 'proc must return an array-like collection of objects '\
            'that each define #id'
          end
        random_results_from(ids)
      end

      def fetch_with_filter
        default_fetch(filter)
      end

      def default_fetch(filter = {})
        ids = klass.where(filter).pluck(:id)
        random_results_from(ids)
      end
    end
  end
end
