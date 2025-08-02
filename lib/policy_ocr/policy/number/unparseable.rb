# frozen_string_literal: true

module PolicyOcr
  module Policy
    class Number
      class Unparseable < Number
        attr_reader :number_lines

        def initialize(number_lines = nil)
          @number_lines = number_lines || generate_default_unparseable_lines
          digital_ints = Array.new(9, PolicyOcr::DigitalInt::Invalid.new(pattern: "???"))
          super(digital_ints)
        end

        def unparseable?
          true
        end

        # Just print the lines as they were provided. This is mostly used for error report output.
        def print_pattern
          puts number_lines.join(PolicyOcr::CARRIAGE_RETURN)
          puts # Add blank separator line
        end

        private

        # If no number_lines are provided, generate some default unparseable lines.
        def generate_default_unparseable_lines
          3.times.map { "?" * 27 }
        end
      end
    end
  end
end
