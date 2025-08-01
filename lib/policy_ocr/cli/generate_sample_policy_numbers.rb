# frozen_string_literal: true

module PolicyOcr
  # rubocop:disable Style/ClassAndModuleChildren
  # Using compact style to avoid conflict with Cli class that inherits from Thor
  class Cli::GenerateSamplePolicyNumbers
    # rubocop:enable Style/ClassAndModuleChildren
    include Interactor

    DEFAULT_VALID_COUNT = 20
    DEFAULT_INVALID_DIGITS_COUNT = 6
    DEFAULT_INVALID_CHECKSUM_COUNT = 4

    # Generates a collection of sample policy numbers for testing purposes.
    # Creates a mix of valid numbers, numbers with invalid digits, and numbers with checksum errors.
    #
    # @param context [Interactor::Context] accepts optional parameters:
    #   - valid_count: number of valid policy numbers to generate (default: 20)
    #   - invalid_digits_count: number of policy numbers with invalid digits (default: 6)
    #   - invalid_checksum_count: number of policy numbers with checksum errors (default: 4)
    # @return [Interactor::Context] prints generated ASCII patterns directly to stdout
    def call
      policy_numbers = Array.new(valid_count) { PolicyOcr::Policy::Number.new(generate_valid_number) } +
                       Array.new(invalid_digits_count) do
                         PolicyOcr::Policy::Number.new(generate_invalid_digits_number)
                       end +
                       Array.new(invalid_checksum_count) { PolicyOcr::Policy::Number.new(generate_invalid_checksum_number) }

      policy_numbers.shuffle.each(&:print_pattern)
    end

    def valid_count
      context.valid_count || DEFAULT_VALID_COUNT
    end

    def invalid_digits_count
      context.invalid_digits_count || DEFAULT_INVALID_DIGITS_COUNT
    end

    def invalid_checksum_count
      context.invalid_checksum_count || DEFAULT_INVALID_CHECKSUM_COUNT
    end

    # Making methods public for testing
    # private

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
      # Start with valid digits, then randomly corrupt 1-3 of them
      valid_digits = Array.new(9) { PolicyOcr::DigitalInt.from_int(rand(10)) }

      # Corrupt 1-3 random positions with reliable invalid patterns
      corrupt_count = rand(1..3)
      positions = (0..8).to_a.sample(corrupt_count)

      # Known invalid patterns that reliably parse but return ?
      invalid_patterns = [
        ' _     _ ',  # Broken horizontal line
        '|_|   |_|',  # Broken vertical structure
        '|||   |||',  # Too many verticals
        '   |  |  ',  # Missing pieces
        ' _ | | _ ',  # Malformed structure
        '|  |_  | ',  # Incomplete sides
        ' _  _  _ ',  # Disconnected segments
        '| |_|_| |'   # Overcomplicated pattern
      ]

      positions.each do |pos|
        valid_digits[pos] = PolicyOcr::DigitalInt::Invalid.new(pattern: invalid_patterns.sample)
      end

      valid_digits
    end

    def generate_invalid_checksum_number
      loop do
        # Generate first 8 digits randomly
        base = Array.new(8) { rand(10) }

        # Try different values for d9 until we get an invalid checksum
        (0..9).each do |d9|
          candidate = base + [d9]
          digital_ints = candidate.map { |d| PolicyOcr::DigitalInt.from_int(d) }
          policy_number = PolicyOcr::Policy::Number.new(digital_ints)

          # Return this combination if it has invalid checksum
          return digital_ints if policy_number.checksum_error?
        end

        # If no d9 value produces invalid checksum, try new base digits
      end
    end
  end
end
