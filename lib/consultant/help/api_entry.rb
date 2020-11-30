module Consultant
  module Help
    module APIEntry
      extend ActiveSupport::Concern
      include Base

      class_methods do 
        def help
          [
            print_method_name,
            print_description,
            print_usage_example,
          ].join("\n\n")
        end

        def indent(array)
          array.map do |str|
            '   ' + str
          end
        end

        def coerce_to_array(entry)
          entry.is_a?(String) ? [entry] : entry
        end

        def print_method_name
          format_header("##{name.split('::').last.underscore}", false)
        end

        def print_description
          indent(coerce_to_array(description)).join("\n")
        end

        def print_usage_example
          header = format_header('Usage', false)
          indent(
            indent(coerce_to_array(usage_example))
              .unshift(header)
          ).join("\n")
        end
      end
    end
  end
end