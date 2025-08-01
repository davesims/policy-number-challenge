# frozen_string_literal: true

module PolicyOcr
  # rubocop:disable Style/ClassAndModuleChildren
  # Using compact style to avoid conflict with Cli class that inherits from Thor
  class Cli::GenerateSamplePolicyNumbers
    # rubocop:enable Style/ClassAndModuleChildren
    include Interactor

    # Generates a collection of sample policy numbers for testing purposes.
    # Creates a mix of valid numbers, numbers with invalid digits, and numbers with checksum errors.
    #
    # @param context [Interactor::Context] accepts optional parameters:
    #   - valid_count: number of valid policy numbers to generate (default: 20)
    #   - invalid_digits_count: number of policy numbers with invalid digits (default: 6)
    #   - invalid_checksum_count: number of policy numbers with checksum errors (default: 4)
    # @return [Interactor::Context] with generated_numbers array containing rendered ASCII strings
    def call
      valid_count = context.valid_count || 20
      invalid_digits_count = context.invalid_digits_count || 6
      invalid_checksum_count = context.invalid_checksum_count || 4

      numbers = Array.new(valid_count) { generate_valid_number } +
                Array.new(invalid_digits_count) { generate_invalid_digits_number } +
                Array.new(invalid_checksum_count) { generate_invalid_checksum_number }

      context.generated_numbers = numbers.shuffle.map { |number| render_number(number) }
    end

    private

    def checksum_valid?(digital_ints)
      PolicyOcr::Policy::Number.new(digital_ints).checksum_valid?
    end

    def generate_valid_number
      loop do
        # Generate first 8 digits randomly
        base = Array.new(8) { rand(10) }

        # Calculate partial sum: d1×1 + d2×2 + ... + d8×8
        partial_sum = base.each_with_index.sum { |digit, i| digit * (i + 1) }

        # Find d9 such that (partial_sum + d9×9) mod 11 = 0
        target_remainder = (-partial_sum) % 11

        (0..9).each do |candidate|
          next unless (candidate * 9) % 11 == target_remainder

          result = base + [candidate]
          # Verify it's actually valid
          digital_ints = result.map { |d| PolicyOcr::DigitalInt.from_int(d) }
          return digital_ints if checksum_valid?(digital_ints)
        end
      end
    end

    def generate_invalid_digits_number
      digits = Array.new(9) { |_i| PolicyOcr::DigitalInt.from_int(rand(10)) }
      # Replace random digits with Invalid patterns (3x3 = 9 chars each)
      wrong_patterns = ["|||   |||", " |    |  ", "___   ___", " _    _  ", "|_|   |_|", "| |   | |", "_|_   _|_",
                        "__|   __|", "|__   |__", "_|    _| "]
      rand(1..3).times do
        digits[rand(9)] = PolicyOcr::DigitalInt::Invalid.new(pattern: wrong_patterns.sample)
      end
      digits
    end

    def generate_invalid_checksum_number
      valid_digits = generate_valid_number
      # Change the last digit to make checksum invalid
      last_digit_value = valid_digits[-1].to_i
      invalid_digit_value = (last_digit_value + rand(1..5)) % 10
      valid_digits[-1] = PolicyOcr::DigitalInt.from_int(invalid_digit_value)
      valid_digits
    end

    def render_number(digits)
      patterns = digits.map(&:pattern)
      lines = patterns.map { |p| p.scan(/.{3}/) }.transpose
      "#{lines.map(&:join).join("\n")}\n"
    end
  end
end
