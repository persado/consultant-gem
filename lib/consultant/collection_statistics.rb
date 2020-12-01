# frozen_string_literal: true

module Consultant
  class CollectionStatistics
    include Usage
    include Utility::FileUtilities
    attr_reader :number_of_runs, :record_collection, :filename
    attr_accessor :results

    def self.call_with_collection_from_proc(
      filename,
      record_type,
      number_of_runs,
      fetch_records_proc,
      &test_code
    )
      call(
        filename,
        record_type,
        number_of_runs,
        fetch_records_proc,
        &test_code
      )
    end

    def self.call_with_collection_from_previous_run(
      filename,
      record_type,
      number_of_runs,
      previous_run_output_filename,
      &test_code
    )
      call(
        filename,
        record_type,
        number_of_runs,
        previous_run_output_filename,
        &test_code
      )
    end

    def self.call(
      filename,
      record_type,
      number_of_runs,
      fetcher_info = nil,
      &test_code
    )
      new(
        filename,
        record_type,
        number_of_runs,
        fetcher_info,
      ).record(&test_code)
    end

    def initialize(
      filename,
      record_type,
      number_of_runs,
      fetcher_info = nil
    )
      @filename = filename
      @number_of_runs = number_of_runs
      @results = []
      @record_collection = Utility::RecordCollection.populate_with(
        record_type,
        number_of_runs,
        fetcher_info
      )
    end

    def record(&block)
      calculate_results!(&block)
      write_results_to_file!
    end

    private

    def calculate_results!(&block)
      number_of_runs.times do
        next_record = record_collection.next
        comment = "#{next_record.class.to_s.downcase} id — #{next_record.id}"
        results << Checkpoint.for_collection_statistics(filename, comment) do
          block.call(next_record)
        end
      end
    end

    def write_results_to_file!
      write_aggregate_data_to_file(results)
    end
  end
end
