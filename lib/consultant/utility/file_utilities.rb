# frozen_string_literal: true

module Consultant
  module Utility
    module FileUtilities
      extend ActiveSupport::Concern

      included do
        def file_path
          @file_path ||=
            "#{Consultant.configuration.results_directory}/#{filename}.txt"
        end

        def file_empty?
          file_path.nil? || !File.file?(file_path) || File.zero?(file_path)
        end

        def write_aggregate_data_to_file(results)
          write_entry_to_file(stats_entry_for(results))
        end

        def separator
          file_empty? ? '' : "\n"
        end

        def query_details(query_opts)
          if query_opts[:count_queries]
            ", queries executed: #{query_opts[:query_count]}"
          end
        end

        def entry_for(
          execution_time,
          opts = { query_count: 0, count_queries: false }
        )
          "#{separator}#{comment}: #{execution_time} seconds#{query_details(opts)}"
        end

        def stats_entry_for(results)
          filtered_results = results.reject { |result| result.is_a?(String) }
          error_warning = generate_collection_stats_error_warning(results, filtered_results)
          stats_array = generate_stats_array(filtered_results)
          [
            "\n",
            error_warning,
          ].concat(stats_array)
            .compact
            .join("\n")
        end

        def generate_stats_array(filtered_results)
          return [] unless filtered_results.length.positive?

          [
            "STATS\n",
            "Average: #{filtered_results.sum / filtered_results.length} seconds",
            "Median: #{filtered_results.sort[filtered_results.length / 2]} seconds",
            "Min: #{filtered_results.min} seconds",
            "Max: #{filtered_results.max} seconds",
            "Total: #{filtered_results.sum} seconds",
          ]
        end

        def generate_collection_stats_error_warning(results, filtered_results)
          if results.length != filtered_results.length
            if filtered_results.length.zero?
              return 'ERROR: Cannot calculate stats: issues found in every run.'
            end

            error_runs = results.length - filtered_results.length
            [
              "WARNING: Errors occured in #{error_runs} runs.",
              "These runs will be filtered out of aggregate stats.\n",
            ].join(' ')
          end
        end

        def error_entry_for(error_message)
          "#{separator}#{comment}: ERROR: #{error_message}"
        end

        def write_entry_to_file(entry)
          mode = file_empty? ? 'w' : 'a'
          File.open(file_path, mode) { |file| file.write(entry) }
        end
      end
    end
  end
end