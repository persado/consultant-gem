# frozen_string_literal: true
module Consultant
  class Checkpoint
    include Usage
    include Utility::FileUtilities
    include Utility::AggregationHelpers
    attr_reader :filename, :comment, :opts

    def self.for_collection_statistics(filename, comment, &test_code)
      opts = OpenStruct.new(return_time?: true)
      call(filename, comment, opts, &test_code)
    end

    def self.aggregate_over_loop(
      filename,
      comment,
      length,
      opts = OpenStruct.new,
      &test_code
    )
      merged_opts = OpenStruct.new(should_aggregate?: true, aggregation_type: :loop, **opts.to_h)
      build_new_tracker_with_length!(length)
      call(filename, comment, merged_opts, &test_code)
    end

    def self.aggregate_over_time(
      filename,
      comment,
      expiration,
      opts = OpenStruct.new,
      &test_code
    )
      tracker = build_new_tracker_with_expiration!(expiration)
      if tracker.is_a?(Utility::AggregationTrackers::ExpiredTracker)
        test_code.call
      else
        merged_opts = OpenStruct.new(should_aggregate?: true, aggregation_type: :time, **opts.to_h)
        call(filename, comment, merged_opts, &test_code)
      end
    end

    def self.call_with_query_count(filename, comment, &test_code)
      opts = OpenStruct.new(count_queries?: true)
      call(filename, comment, opts, &test_code)
    end

    def self.aggregate_over_loop_with_query_count(filename, comment, length, &test_code)
      opts = OpenStruct.new(count_queries?: true)
      aggregate_over_loop(filename, comment, length, opts, &test_code)
    end

    def self.aggregate_over_time_with_query_count(filename, comment, expiration, &test_code)
      opts = OpenStruct.new(count_queries?: true)
      aggregate_over_time(filename, comment, expiration, opts, &test_code)
    end

    def self.call(
      filename,
      comment,
      opts = OpenStruct.new,
      &test_code
    )
      checkpoint = new(filename, comment, opts)
      if opts.should_aggregate?
        checkpoint.record_with_aggregations(&test_code)
      else
        checkpoint.record(&test_code)
      end
    end

    def initialize(filename, comment, opts)
      @filename = filename
      @comment = comment
      @opts = opts
    end

    def record(&test_code)
      results = measure(&test_code)
      write_results_to_file!(results)
      results.return_value
    rescue StandardError => e
      handle_error(e.message)
    end

    def record_with_aggregations(&test_code)
      results = measure(&test_code)
      update_current_tracker(results)
      if aggregation_finished?
        write_results_to_file!(agg_results)
        delete_current_tracker!
      end
      results.return_value
    rescue StandardError => e
      handle_error(e.message)
    end

    def measure(&test_code)
      start_time = Time.zone.now
      runner_results = Runner.run(opts, &test_code)
      finish_time = Time.zone.now
      execution_time = finish_time - start_time
      Results.new(
        execution_time,
        runner_results.proc_output,
        runner_results.query_count,
        opts,
      )
    end

    def write_results_to_file!(results)
      entry = generate_entry(results)
      write_entry_to_file(entry)
    end

    def handle_error(error_message)
      entry = error_entry_for(error_message)
      write_entry_to_file(entry)
      error_message
    end

    def generate_entry(results)
      entry_for(
        results.execution_time,
        {
          query_count: results.query_count,
          count_queries: results.include_query_data?,
        },
      )
    end

    def agg_results
      @agg_results ||=
        Results.new(
          current_totals[:time],
          nil,
          current_totals[:queries],
          opts,
        )
    end
  end
end
