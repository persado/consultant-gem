# frozen_string_literal: true

module Consultant
  module Help
    class OrderedAPIList
      attr_accessor :class_name

      def self.for(class_name)
        new(class_name).print
      end

      def initialize(class_name)
        @class_name = class_name.split('::').last
      end

      def print
        api_classes = sort_files_by_priority.map do |method_name|
          camelcase_method = ActiveSupport::Inflector.camelize(method_name)
          ActiveSupport::Inflector.constantize(
            "Consultant::Help::#{class_name}API::#{camelcase_method}"
          )
        end
        api_classes.map(&:help)
      end

      private

      def directory_name
        formatted_class_name = ActiveSupport::Inflector.underscore(
          class_name
        ).downcase
        "#{Consultant.configuration.root}/consultant/help/#{formatted_class_name}_api"
      end

      def files
        @files ||= Dir["#{directory_name}/*"]
      end

      def extract_method_from_filename(filename)
        filename.split('/').last.split('.rb').first
      end

      def method_names
        @method_names ||= files.map do |filename|
          extract_method_from_filename(filename)
        end
      end

      def sort_files_by_priority
        sorted = []
        root_name = method_names.find do |method_name|
          method_name == 'call'
        end
        queue = [root_name]
        until queue.empty?
          node = queue.shift
          children = find_children_of(node)
          sorted << node
          queue += children
        end
        sorted
      end

      def find_children_of(name)
        if name == 'call'
          find_top_level_children
        else
          method_names.select do |method_name|
            next if method_name == name

            method_name.match(name).present?
          end
        end
      end

      def find_top_level_children
        primary = method_names.select do |method_name|
          next if method_name == 'call'

          method_name.match('call').present?
        end
        secondary = find_top_level_nodes
        primary + secondary
      end

      def find_top_level_nodes
        method_names.select do |method_name|
          next if method_name == 'call'

          parents = method_names.select do |potential_parent|
            next if potential_parent == method_name

            method_name.match(potential_parent).present?
          end
          parents.empty?
        end
      end
    end
  end
end
