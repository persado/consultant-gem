# frozen_string_literal: true

module Consultant
  class Runner
    attr_reader :should_count_queries

    def self.run(opts, &test_code)
      new(opts).call(&test_code)
    end

    def initialize(opts)
      @should_count_queries = opts.count_queries?
    end

    def call(&test_code)
      if should_count_queries
        counter = QueryCounter.count(&test_code)
        results_for(counter.output, counter.count)
      else
        results_for(test_code.call)
      end
    end

    def results_for(output, count = 0)
      OpenStruct.new(
        proc_output: output,
        query_count: count,
      )
    end
  end
end
