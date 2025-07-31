# frozen_string_literal: true

module PolicyOcr
  module Parser
    class ParsePolicyNumberLine
      include Interactor
      include Interactor::Validations

      before do
        validate_presence_of(:number_line, :index)
        validate_size(:number_line, PolicyOcr::LINE_HEIGHT)
      end

      on_validation_failed do
        # Set an Invalid policy number in the context if validation fails, so that there is 
        # no nil policy_number in the context.
        context.policy_number = PolicyOcr::Policy::Number::Invalid.new
      end

      # Parses a PolicyOcr::LINE_HEIGHT-length array representing a single policy number.
      #
      # Example input:
      #  number_line = [
      #  " _  _     _  _  _  _  _ ",
      #  "|_||_||_||_ |_   ||_||_|",
      #  " _| _|  | _||_|  ||_| _|",
      #  ]
      #
      # @param context [Interactor::Context] must contain number_line and index
      # @return [Interactor::Context] result with policy_number set
      def call
        PolicyOcr.logger_for(self).debug("Parsing policy number at line #{index}...")
        context.policy_number = PolicyOcr::Policy::Number.new(digital_ints)
        PolicyOcr.logger_for(self).debug("Parsed policy number #{context.policy_number.to_s} at line #{index}...")
      rescue StandardError => e
        PolicyOcr.logger_for(self).error("Failed to parse policy number at line #{index}: #{e.message}")
        context.policy_number = PolicyOcr::Policy::Number::Invalid.new
        context.fail!(error: "Malformed number line at #{index}: #{e.message} #{e.backtrace.first}")
      end

      private 

      # digital_ints creates an array of DigitalInt objects from the matching digit patterns.
      def digital_ints
        digital_patterns.map do |pattern|
          PolicyOcr::DigitalInt.from_pattern(pattern)
        end
      end

      # digital_patterns extracts the digit patterns representing one policy number from the number_line.
      # These can be used to create DigitalInt objects.
      def digital_patterns
        number_line
          .map(&:chars) # convert each string to chars
          .map {|l| l.each_slice(PolicyOcr::DIGIT_WIDTH).to_a } # split each line into char arrays of digit width
          .transpose # transpose the outer array from 3x9 to 9x3, which will group characters by digit
          .map(&:join) # join each group of characters back into a string, which will be the digit pattern
      end

      def number_line = context.number_line
      def index = context.index
    end
  end
end
