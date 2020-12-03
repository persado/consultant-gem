# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'consultant'
  s.version     = '0.0.0'
  s.date        = '2020-11-24'
  s.summary     = "A suite of tools for pinpointing inefficiencies\n"\
    'and measuring and presenting performance improvements'
  s.description = 'Description TBD'
  s.authors     = ['Chris Ruenes, Eitan Bar-David, Noah Levin']
  s.email       = 'ruenes.chris@gmail.com'
  s.files       = [
    'lib/consultant.rb',
    'lib/consultant/checkpoint.rb',
    'lib/consultant/collection_statistics.rb',
    'lib/consultant/query_counter.rb',
    'lib/consultant/results.rb',
    'lib/consultant/usage.rb',
    'lib/consultant/csv_generator.rb',
    'lib/consultant/help/api_entry.rb',
    'lib/consultant/help/base.rb',
    'lib/consultant/help/checkpoint.rb',
    'lib/consultant/help/collection_statistics.rb',
    'lib/consultant/help/combined_functionality.rb',
    'lib/consultant/help/ordered_api_list.rb',
    'lib/consultant/help/checkpoint_api/aggregate_over_loop_with_query_count.rb',
    'lib/consultant/help/checkpoint_api/aggregate_over_loop.rb',
    'lib/consultant/help/checkpoint_api/aggregate_over_time_with_query_count.rb',
    'lib/consultant/help/checkpoint_api/aggregate_over_time.rb',
    'lib/consultant/help/checkpoint_api/call_with_query_count.rb',
    'lib/consultant/help/checkpoint_api/call.rb',
    'lib/consultant/help/collection_statistics_api/call_with_collection_from_previous_run.rb',
    'lib/consultant/help/collection_statistics_api/call_with_collection_from_proc.rb',
    'lib/consultant/help/collection_statistics_api/call.rb',
    'lib/consultant/utility/aggregation_helpers.rb',
    'lib/consultant/utility/file_utilities.rb',
    'lib/consultant/utility/record_collection.rb',
    'lib/consultant/utility/record_fetcher_helpers.rb',
    'lib/consultant/utility/record_fetcher.rb',
    'lib/consultant/utility/aggregation_trackers/base.rb',
    'lib/consultant/utility/aggregation_trackers/collection_aggregation_tracker.rb',
    'lib/consultant/utility/aggregation_trackers/duration_aggregation_tracker.rb',
    'lib/consultant/utility/aggregation_trackers/expired_tracker.rb',
    'lib/consultant/csv_utility/additional_cells_generator.rb',
    'lib/consultant/csv_utility/formatting_utilities.rb',
    'lib/consultant/csv_utility/matrix.rb',
    'lib/consultant/csv_utility/parsers.rb',
    'lib/consultant/csv_utility/rows_generator.rb',
    'lib/consultant/csv_utility/validations.rb',
  ]
  s.add_runtime_dependency 'actionpack', ['~> 5.1']
  s.add_runtime_dependency 'activesupport', ['~> 5.1']
  s.add_runtime_dependency 'axlsx', ['~> 2.0']
  s.add_runtime_dependency 'caxlsx_rails', ['~> 0.6']
  s.homepage =
    'https://rubygems.org/gems/consultant'
  s.license = 'MIT'
end
