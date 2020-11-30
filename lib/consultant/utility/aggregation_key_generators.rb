# frozen_string_literal: true

module Consultant
  module Utility
    module AggregationKeyGenerators
      TRACE_EXCLUSION_REGEX =
        %r{\(pry\)|\/gems\/|\/consultant\/utility|\/consultant\/checkpoint}.freeze

      def self.for_loop
        "#{thread_id}-#{calling_line}".hash
      end

      def self.for_time
        calling_line.hash
      end

      def self.calling_line
        Thread.current.backtrace
          .reject { |trace| trace.match(TRACE_EXCLUSION_REGEX) }
          .first
      end

      def self.thread_id
        Thread.current.object_id
      end
    end
  end
end
