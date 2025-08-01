# frozen_string_literal: true

module PolicyOcr
  module Parser
    class ParsePolicyNumberLine
      include Interactor
      include Interactor::Validations

      before do
        validate_presence_of(:number_line, :index)
        validate_size(:number_line, PolicyOcr::LINE_HEIGHT)
        validate_structure
      end

      on_validation_failed do
        # Set an Unparseable policy number in the context if validation fails, so that there is
        # no nil policy_number in the context.
        context.policy_number = PolicyOcr::Policy::Number::Unparseable.new
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
        logger.debug("Parsing policy number at line #{index}...")
        context.policy_number = PolicyOcr::Policy::Number.new(digital_ints)
        logger.debug("Parsed policy number #{context.policy_number} at line #{index}...")
      rescue StandardError => e
        handle_parsing_error(e)
      end

      private

      def validate_structure
        # Use the validate method from Interactor::Validations to check structural integrity
        validate(character_alignment_error_message) do
          context.number_line.all? { |line| (line.length % PolicyOcr::DIGIT_WIDTH).zero? }
        end

        validate(digit_count_error_message) do
          line_digit_counts = context.number_line.map { |line| line.length / PolicyOcr::DIGIT_WIDTH }
          line_digit_counts.all? { |count| count == PolicyOcr::DIGITS_PER_LINE }
        end
      end

      def character_alignment_error_message
        message = "Line #{context.index + 1}: Lines must be divisible by #{PolicyOcr::DIGIT_WIDTH} characters " \
                  "for proper digit parsing"
        message += "\n#{format_offending_lines}"
        message += "\n"
        message
      end

      def digit_count_error_message
        message = "Line #{context.index + 1}: All lines must have exactly #{PolicyOcr::DIGITS_PER_LINE} digits"
        message += "\n#{format_offending_lines}"
        message += "\n"
        message
      end

      def format_offending_lines
        lines_with_info = context.number_line.map do |line|
          char_count = line.length
          digit_count = char_count / PolicyOcr::DIGIT_WIDTH
          "  \"#{line}\" (#{char_count} chars, #{digit_count} digits)"
        end
        lines_with_info.join("\n")
      end

      def handle_parsing_error(error)
        logger.error("Failed to parse policy number at line #{index + 1}: #{error.message}")
        context.policy_number = PolicyOcr::Policy::Number::Unparseable.new
        error_message = "Line #{index + 1}: #{error.message}\n#{format_offending_lines}\n"
        context.fail!(error: error_message)
      end

      # digital_ints creates an array of DigitalInt objects from the matching digit patterns.
      def digital_ints
        digital_patterns.map do |pattern|
          PolicyOcr::DigitalInt.from_pattern(pattern)
        end
      end

      # digital_patterns extracts the digit patterns representing one policy number from the number_line.
      # These patterns are used to create DigitalInt objects.
      def digital_patterns
        number_line
          .map(&:chars) # convert each string to chars
          .map { |l| l.each_slice(PolicyOcr::DIGIT_WIDTH).to_a } # split each line into char arrays of digit width
          .transpose # transpose the outer array from 3x9 to 9x3, which will group characters by digit
          .map(&:join) # join each group of characters back into a string, which will be the digit pattern
      end

      def number_line
        context.number_line
      end

      def index
        context.index
      end

      def logger
        PolicyOcr.logger_for(self)
      end
    end
  end
end
