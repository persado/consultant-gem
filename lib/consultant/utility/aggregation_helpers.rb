# frozen_string_literal: true

module Consultant
  module Utility
    module AggregationHelpers
      extend ActiveSupport::Concern

      class_methods do
        def aggregation_trackers
          @aggregation_trackers ||= {}
        end

        def build_new_tracker_with_length!(length)
          key = AggregationKeyGenerators.for_loop
          aggregation_trackers[key] ||=
            AggregationTrackers::CollectionAggregationTracker.new(length)
        end

        def build_new_tracker_with_expiration!(expiration)
          key = AggregationKeyGenerators.for_time
          current_tracker = aggregation_trackers[key]
          if current_tracker.nil?
            if expiration <= Time.zone.now
              AggregationTrackers::ExpiredTracker.instance
            else
              aggregation_trackers[key] =
                AggregationTrackers::DurationAggregationTracker.new(expiration)
            end
          else
            current_tracker
          end
        end
      end

      included do
        delegate :current_totals, to: :current_tracker

        def generate_current_tracker_key
          case opts.aggregation_type
          when :loop
            AggregationKeyGenerators.for_loop
          when :time
            AggregationKeyGenerators.for_time
          else
            raise "Invalid aggregation type.\n"\
              'Aggregation must be over either a loop or a period of time'
          end
        end

        def current_tracker
          self.class.aggregation_trackers[generate_current_tracker_key]
        end

        def current_tracker=(tracker)
          self.class.aggregation_trackers[generate_current_tracker_key] = tracker
        end

        def aggregation_finished?
          current_tracker.final?
        end

        def update_current_tracker(results)
          current_tracker.add(results.execution_time, results.query_count)
        end

        def delete_current_tracker!
          self.class.aggregation_trackers.delete(generate_current_tracker_key)
        end
      end
    end
  end
end
