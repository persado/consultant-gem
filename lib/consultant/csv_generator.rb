# frozen_string_literal: true

module Consultant
  class CsvGenerator
    attr_reader :files

    include CsvUtility::Validations

    def self.merge_files_and_compare(
      export_filename,
      *files,
      additional_columns: {}
    )
      new(export_filename, files, additional_columns).generate_csv
    end

    def initialize(export_filename, files, additional_columns)
      @export_filename = export_filename
      @files = files
      @additional_columns = additional_columns
      @data_matrix = CsvUtility::Matrix.new
      @aggregate_data_matrix = CsvUtility::Matrix.new
    end

    def generate_csv
      validate!
      extract_data_from_files!
      write_data_to_xlsx!
    end

    private

    def validate!
      validate_consistency_of_data!(files)
      validate_file_format!(files)
    end

    def extract_data_from_files!
      files.each do |filename|
        system_name = CsvUtility::Parsers.system_name_for(filename)
        File.open(system_name, 'r') do |file|
          file.each do |line|
            cell_data = CsvUtility::Parsers.extract_cell_data_from(line)
            next if cell_data.nil?

            row_name = CsvUtility::Parsers.extract_row_name_from(line)
            set_row_data(filename, row_name, cell_data)
          end
        end
      end
    end

    def write_data_to_xlsx!
      rendered_string = ActionController::Base.renderer.render(
        :xlsx,
        template: 'results_csv.xlsx',
        assigns: template_variables,
        name: @export_filename,
      )
      File.open(
        "#{Consultant.configuration.results_directory}/#{@export_filename}.xlsx.axlsx", 'w'
      ) do |file|
        file.write(rendered_string)
      end
    end

    def headers
      @headers ||=
        files.map { |file| CsvUtility::Parsers.display_name_for(file) }
    end

    def template_variables
      modified_headers = headers + @additional_columns.keys
      {
        headers: modified_headers,
        rows: CsvUtility::RowsGenerator.call(
          @data_matrix,
          headers,
          additional_columns: @additional_columns,
        ),
        aggregate_rows: CsvUtility::RowsGenerator.call(
          @aggregate_data_matrix,
          headers,
          for_aggregate_rows: true,
        ),
      }
    end

    def set_row_data(filename, row_name, cell_data)
      display_filename =
        CsvUtility::Parsers.display_name_for(filename)
      if CsvUtility::Parsers.aggregate_row?(row_name)
        @aggregate_data_matrix[display_filename, row_name] = cell_data
      else
        @data_matrix[display_filename, row_name] = cell_data
      end
    end
  end
end
