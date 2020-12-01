# frozen_string_literal: true

module Consultant
  module Help
    module Checkpoint
      extend ActiveSupport::Concern
      include Help::Base

      class_methods do
        def description
          [
            'Checkpoint is used to measure how long a block of code takes to run,',
            '(and optionally, how many database queries run within the block).',
            'Each call to Checkpoint is passed a filename to write to,',
            'a label to use in order to identify this particular test in that file,',
            'and a block of code to execute. Checkpoint will always return the',
            'return value of the wrapped block, which makes it able to wrap',
            'existing code with limited need for refactoring.',
          ]
        end
      end
    end
  end
end
