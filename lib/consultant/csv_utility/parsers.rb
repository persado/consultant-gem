# frozen_string_literal: true

module Consultant
  module CsvUtility
    class Parsers
      def self.extract_row_name_from(line)
        line.split(': ').first
      end

      def self.extract_cell_data_from(line)
        time_data = line.slice(/[\d\.]+ seconds/)
        time_data.nil? ? nil : time_data.match(/[\d\.]+/)[0]
      end

      def self.system_name_for(file)
        if file.is_a?(Hash)
          "#{Consultant.configuration.results_directory}/#{file.keys.first}.txt"
        else
          "#{Consultant.configuration.results_directory}/#{file}.txt"
        end
      end

      def self.display_name_for(file)
        file.is_a?(Hash) ? file.values.first : file
      end

      def self.extract_id_from(row_name)
        row_name.match(/(\d+)/)[1]
      end

      def self.extract_class_name_from(row_name)
        row_name.match(/\w+/)[0]
      end

      def self.aggregate_row?(row_name)
        %w[average median max min total].include?(row_name.downcase)
      end

      def self.extract_row_names_from(file)
        row_names = []
        File.open(system_name_for(file), 'r') do |opened_file|
          opened_file.each do |line|
            row_names << extract_row_name_from(line)
          end
        end
        row_names
      end
    end
  end
end
