# frozen_string_literal: true
module Consultant
  module Help
    module CheckpointAPI
      module Call
        include Help::APIEntry

        def self.description
          'Basic call for Checkpoint.'
        end

        def self.usage_example
          [
            'Checkpoint.call(',
            '   output filename,',
            '   label,',
            ') do ',
            '   test code/wrapped code here...',
            'end',
          ]
        end
      end
    end
  end
end
