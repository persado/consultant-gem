# frozen_string_literal: true

module Consultant
  class QueryCounter
    attr_reader :count, :callback, :output

    def self.count(&test_code)
      counter = new
      counter.record_queries(&test_code)
      counter
    end

    def initialize
      @count = 0
      @callback = ->(_, _, _, _, payload) {
        @count += 1 unless payload[:name] == 'SCHEMA' || payload[:cached]
      }
      @output = nil
    end

    def record_queries(&test_code)
      ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
        @output = test_code.call
      end
    end
  end
end
