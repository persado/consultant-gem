# frozen_string_literal: true

module Consultant
  module Help
    module Base
      extend ActiveSupport::Concern
      class_methods do
        def help(internal: false)
          full_message = [
            print_description,
            print_api,
          ].join("\n\n")
          if internal
            "\n#{full_message}\n"
          else
            print(
              "\n#{full_message}\n",
            )
          end
        end

        private

        def description
          ["No description available for #{self.class}"]
        end

        def format_header(header, include_newline = true)
          suffix = include_newline ? "\n" : ''
          header.upcase + suffix
        end

        def print_description
          header = format_header('Description')
          description.unshift(header).join("\n")
        end

        def print_api
          header = format_header('###Api###', false)
          OrderedAPIList.for(name).unshift(header).join("\n\n")
        end
      end
    end
  end
end
