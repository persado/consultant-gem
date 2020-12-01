# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object'
require 'active_support/time_with_zone'
require 'active_support/core_ext/module/delegation'
require 'ostruct'
require 'singleton'

require 'consultant/configuration'

require 'consultant/query_counter'
require 'consultant/results'
require 'consultant/runner'

require 'consultant/help/ordered_api_list'
require 'consultant/help/base'
require 'consultant/help/api_entry'
require 'consultant/help/combined_functionality'

require 'consultant/help/checkpoint_api/aggregate_over_loop_with_query_count'
require 'consultant/help/checkpoint_api/aggregate_over_loop'
require 'consultant/help/checkpoint_api/aggregate_over_time_with_query_count'
require 'consultant/help/checkpoint_api/aggregate_over_time'
require 'consultant/help/checkpoint_api/call_with_query_count'
require 'consultant/help/checkpoint_api/call'
require 'consultant/help/collection_statistics_api/call_with_collection_from_previous_run'
require 'consultant/help/collection_statistics_api/call_with_collection_from_proc'
require 'consultant/help/collection_statistics_api/call'

require 'consultant/help/checkpoint'
require 'consultant/help/collection_statistics'
require 'consultant/usage'

require 'consultant/utility/aggregation_trackers/base'
require 'consultant/utility/aggregation_trackers/collection_aggregation_tracker'
require 'consultant/utility/aggregation_trackers/expired_tracker'
require 'consultant/utility/aggregation_trackers/duration_aggregation_tracker'
require 'consultant/utility/aggregation_key_generators'
require 'consultant/utility/aggregation_helpers'
require 'consultant/utility/file_utilities'
require 'consultant/utility/record_fetcher_helpers'
require 'consultant/utility/record_fetcher'
require 'consultant/utility/record_collection'

require 'consultant/checkpoint'
require 'consultant/collection_statistics'

module Consultant
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  delegate :configured?, to: :configuration

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.configured?
    configuration.configured?
  end
end
