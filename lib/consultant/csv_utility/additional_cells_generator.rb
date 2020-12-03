# frozen_string_literal: true

module Consultant
  module CsvUtility
    class AdditionalCellsGenerator
      attr_reader :row_name, :data_calculators_per_column

      def self.call(row_name, data_calculators_per_column)
        new(row_name, data_calculators_per_column).generate
      end

      def initialize(row_name, data_calculators_per_column)
        @row_name = row_name
        @data_calculators_per_column = data_calculators_per_column
      end

      def generate
        class_name = Parsers.extract_class_name_from(row_name)
        klass = class_name.titleize.constantize
        model_id = Parsers.extract_id_from(row_name)
        model = klass.find(model_id)
        data_calculators_per_column.map do |_, calculator|
          calculator.call(model)
        end
      end
    end
  end
end
