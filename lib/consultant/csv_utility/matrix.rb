# frozen_string_literal: true

module Consultant
  module CsvUtility
    class Matrix
      attr_reader :inner_keys
      def initialize
        @data = Hash.new { |h, k| h[k] = {} }
        @inner_keys = Set.new
      end

      def []=(filename, test_id, data)
        @data[filename][test_id] = data
        @inner_keys << test_id
      end

      def [](*args)
        case args.size
        when 1
          @data[args[0]]
        when 2
          @data[args[0]][args[1]]
        end
      end
    end
  end
end
