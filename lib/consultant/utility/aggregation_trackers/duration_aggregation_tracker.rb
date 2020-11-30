# frozen_string_literal: true

module Consultant
  module Utility
    module AggregationTrackers
      class DurationAggregationTracker < Base
        attr_reader :expiration
        def initialize(expiration)
          @expiration = expiration
          super()
        end

        def add(time, queries)
          return if expired?

          super
        end

        def final?
          Time.zone.now >= expiration
        end

        alias expired? final?
      end
    end
  end
end
