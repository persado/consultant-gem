# frozen_string_literal: true

module Consultant
  module CsvUtility
    class FormattingUtilities
      def self.decorate(contents)
        extremes = find_extremes(contents)
        contents.map.with_index do |entry, index|
          {
            contents: entry,
            style: determine_style_for(index, extremes),
          }
        end
      end

      def self.find_extremes(contents)
        float_data = contents.map do |entry|
          entry.gsub(' seconds', '').to_f
        end
        [
          float_data.find_index(float_data.max),
          float_data.find_index(float_data.min),
        ]
      end

      def self.determine_style_for(index, extremes)
        max_index, min_index = extremes
        case index
        when max_index
          'max'
        when min_index
          'min'
        end
      end

      private_class_method :find_extremes, :determine_style_for
    end
  end
end
