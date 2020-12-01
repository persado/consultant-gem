# frozen_string_literal: true

module Consultant
  module Usage
    extend ActiveSupport::Concern

    included do
      base_path = 'Consultant::Help'
      filename = name.split('::').last
      include ActiveSupport::Inflector.constantize(
        "#{base_path}::#{filename}"
      )
    end
  end
end