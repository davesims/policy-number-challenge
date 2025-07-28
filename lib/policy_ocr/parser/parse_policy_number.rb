# frozen_string_literal: true

module PolicyOcr
  module Parser
    class ParsePolicyNumber
      include Interactor

      def call
        policy_number = PolicyOcr::Policy::Number.new(digital_ints)
        context.policy_number = policy_number
      end

      def digital_ints
        digital_patterns.map do |pattern|
          PolicyOcr::DigitalInt.from_pattern(pattern)
        end
      end

      def digital_patterns
        line
          .map(&:chars) # convert each string to chars
          .map {|l| l.each_slice(PolicyOcr::DIGIT_WIDTH).to_a } # split each line into char arrays of digit width
          .transpose # transpose the outer array from 4x9 to 9x4, which will group characters by digit
          .map(&:join) # join each group of characters back into a string, which will be the digit pattern
      end

      def line = @line ||= context.line
    end
  end
end
