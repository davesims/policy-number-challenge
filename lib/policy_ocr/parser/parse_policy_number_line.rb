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

      # Parses a PolicyOcr::LINE_HEIGHT-length array representing a single policy number.
      #
      # Example input:
      #  number_line = [
      #  " _  _     _  _  _  _  _ ",
      #  "|_||_||_||_ |_   ||_||_|",
      #  " _| _|  | _||_|  ||_| _|",
      #  "                        "
      #  ]
      #
      # @param context [Interactor::Context] must contain number_line and index
      # @return [Interactor::Context] result with policy_number set
      def call
        PolicyOcr.logger.info("Parsing policy number at line #{index}...")
        policy_number = PolicyOcr::Policy::Number.new(digital_ints)
        context.policy_number = policy_number
      rescue StandardError => e
        # If something goes really wrong, set the Invalid policy number
        # log an error and continue processing. 
        context.policy_number = PolicyOcr::Policy::Number::Invalid.new
        PolicyOcr.logger.error("Failed to parse policy number at line #{index}: #{e.message}")
        context.fail!(error: "Failed to parse policy number line: #{e.message}")
      end

      private 

      # digital_ints creates an array of DigitalInt objects 
      # from the matching digit patterns.
      def digital_ints
        digital_patterns.map do |pattern|
          PolicyOcr::DigitalInt.from_pattern(pattern)
        end
      end

      # digital_patterns extracts the digit patterns representing one 
      # policy number from the number_line. These can be used to 
      # create DigitalInt objects.
      def digital_patterns
        number_line
          .map(&:chars) # convert each string to chars
          .map {|l| l.each_slice(PolicyOcr::DIGIT_WIDTH).to_a } # split each line into char arrays of digit width
          .transpose # transpose the outer array from 4x9 to 9x4, which will group characters by digit
          .map(&:join) # join each group of characters back into a string, which will be the digit pattern
      end

      def number_line = context.number_line
      def index = context.index
    end
  end
end
