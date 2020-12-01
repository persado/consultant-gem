# frozen_string_literal: true

module Consultant
  class Results
    attr_reader(
      :execution_time,
      :query_count,
      :proc_output,
      :should_return_time,
      :include_query_data
    )
    def initialize(execution_time, proc_output, query_count, opts)
      @execution_time = execution_time
      @proc_output = proc_output
      @include_query_data = opts.count_queries?
      @query_count = @include_query_data ? query_count : 0
      @should_return_time = opts.return_time?
    end

    def return_value
      should_return_time ? execution_time : proc_output
    end

    def include_query_data?
      include_query_data
    end
  end
end