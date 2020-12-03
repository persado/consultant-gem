# frozen_string_literal: true

module Benchmarking
  module AggregateTests
    module Utility
      class GenerateControllerTestCode

        SPACES_PER_TAB = 2

        attr_reader :model_name, :endpoint_sexp, :endpoint_name, :indentations

        def self.for(model_name, endpoint_name, indentations: 0)
          new(model_name, endpoint_name, indentations: indentations).generate
        end

        def initialize(model_name, endpoint_name, indentations: 0)
          @model_name = model_name.to_s
          @endpoint_name = endpoint_name
          @endpoint_sexp = extract_method(endpoint_name)
          @indentations = indentations
        end

        def filename
          @filename ||= "app/controllers/#{model_name.pluralize}_controller.rb"
        end

        def file_sexp
          @file_sexp ||= File.open(filename, 'r') { |file| RubyParser.new.parse(file.read) }
        end

        def extract_method(endpoint_name)
          file_sexp.find_nodes(:defn).find { |node| node.second == endpoint_name.downcase.to_sym }
          # TODO: rescue errors and return saying method does not exist
        end

        def generate
          required_methods = detect_required_methods
          method_sexps = find(required_methods)
          validate_required_methods!(required_methods, method_sexps)
          endpoint_method = stringify_and_add_ivar_to_test_code
          dependencies = method_sexps.map { |method_sexp| stringify(method_sexp) }
          indent(dependencies.unshift(endpoint_method).join("\n\n"))
        end

        private

        def validate_required_methods!(required_methods, found_methods)
          missing_methods = required_methods.select.with_index do |_, idx|
            found_methods[idx].nil?
          end
          unless missing_methods.empty?
            message = "The following method(s) are not defined in any relevant context:\n"\
            "#{missing_methods.join("\n")}\n"\
            "methods must be defined in one of the following three place:\n"\
            "#{model_name.pluralize}Controller\n"\
            "ControllerTest\n"\
            "#{model_name.pluralize}Controllor#{endpoint_name.titleize}"
            raise message
          end
        end

        def stringify_and_add_ivar_to_test_code
          stringified = stringify(endpoint_sexp)
          stringified.sub("def #{endpoint_name}", "def #{endpoint_name}(model)\n  @model = model")
        end

        def stringify(sexp)
          Ruby2Ruby.new.process(sexp)
        end

        def detect_required_methods
          # TODO: this only works one level deep right now.
          # Or maybe it actually doesn't...it may work at all layers.
          # but, it doesn't change the fact that there is a bunch of
          # fake, convenient traversal in this code. It should more
          # properly engage with the sexp API.
          controller_methods = detect_all_methods_in(controller_test_file_sexp)
          shared_controller_methods = detect_all_methods_in(shared_controller_test_file_sexp)
          detect_undefined_methods - controller_methods - shared_controller_methods
        end

        def detect_undefined_methods
          flat_endpoint_sexp = endpoint_sexp.flatten
          flat_endpoint_sexp.select.with_index do |_, index|
            flat_endpoint_sexp[index - 1].nil? && flat_endpoint_sexp[index - 2] == :call
          end
        end

        def shared_controller_test_file_sexp
          @shared_controller_test_file_sexp ||=
            File.open('app/services/benchmarking/aggregate_tests/controller_test.rb', 'r') do |file|
              RubyParser.for_current_ruby.parse(file.read)
            end
        end

        def controller_test_file_sexp
          @controller_test_file_sexp ||=
            File.open(
              "app/services/benchmarking/aggregate_tests/#{model_name.pluralize}"\
              "_controller_#{endpoint_name}.rb",
            ) do |file|
              RubyParser.for_current_ruby.parse(file.read)
            end
        end

        def detect_all_methods_in(sexp)
          flattened = sexp.flatten
          flattened.select.with_index do |_, idx|
            flattened[idx - 1] == :defn
          end
        end

        def find(methods)
          methods_in_file = file_sexp.find_nodes(:defn)
          methods.map do |method|
            methods_in_file.find do |node|
              node.second == method
            end
          end
        end

        def indent(str)
          return str if indentations.zero?

          indented_arr = str.split("\n").map.with_index do |line, index|
            if index.zero?
              line
            elsif line.blank?
              line
            else
              (' ' * SPACES_PER_TAB * indentations) + line
            end
          end

          indented_arr.join("\n")
        end
      end
    end
  end
end
