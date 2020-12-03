# frozen_string_literal: true

module Consultant
  module CsvUtility
    class RowsGenerator
      attr_reader :data_matrix, :headers, :additional_columns, :for_aggregate_rows

      def self.call(
        data_matrix,
        headers,
        additional_columns: {},
        for_aggregate_rows: false
      )
        new(data_matrix, headers, additional_columns, for_aggregate_rows).generate
      end

      def initialize(data_matrix, headers, additional_columns, for_aggregate_rows)
        @data_matrix = data_matrix
        @headers = headers
        @additional_columns = additional_columns
        @for_aggregate_rows = for_aggregate_rows
      end

      def generate
        row_names = data_matrix.inner_keys
        row_names.map do |row_name|
          contents = headers.map { |header| data_matrix[header, row_name] }
          base_row = FormattingUtilities.decorate(contents)
          add_row_title_to!(base_row, row_name) + additional_cells_for(row_name)
        end
      end

      private

      def add_row_title_to!(row, title)
        formatted_title = for_aggregate_rows ? title : Parsers.extract_id_from(title)
        row.unshift(
          {
            contents: formatted_title,
            style: nil,
          },
        )
      end

      def additional_cells_for(row_name)
        return [] if additional_columns.empty?

        additional_cells = AdditionalCellsGenerator.call(
          row_name,
          additional_columns,
        )
        additional_cells.map do |cell_data|
          {
            contents: cell_data,
            style: nil,
          }
        end
      end
    end
  end
end
