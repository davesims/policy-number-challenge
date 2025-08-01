# frozen_string_literal: true

#
# This class represents a single parsed policy number as an array of DigitalChar objects.
#
module PolicyOcr
  module Policy
    class Number
      INVALID_DIGITS_MESSAGE = "ILL"
      CHECKSUM_ERROR_MESSAGE = "ERR"

      attr_reader :digital_ints

      def initialize(digital_ints)
        @digital_ints = digital_ints
      end

      def all_digits_valid?
        return false if digital_ints.empty?

        digital_ints.all?(&:valid?)
      end

      def checksum_valid?
        PolicyOcr::ValidatePolicyNumberChecksum.call(policy_number: self).success?
      end

      def to_s
        "#{digital_ints.map(&:to_s).join} #{message}"
      end

      def to_a
        digital_ints.map(&:int_value)
      end

      def message
        return INVALID_DIGITS_MESSAGE unless all_digits_valid?
        return CHECKSUM_ERROR_MESSAGE unless checksum_valid?

        ""
      end

      def valid?
        all_digits_valid? && checksum_valid?
      end

      def checksum_error?
        all_digits_valid? && !checksum_valid?
      end

      def invalid_digits?
        !all_digits_valid?
      end

      def parseable?
        true
      end

      def unparseable?
        false
      end

      def print_pattern
        patterns = digital_ints.map(&:pattern)
        lines = patterns.map { |p| p.scan(/.{3}/) }.transpose
        lines.each { |line| puts line.join }
        puts # Add blank separator line
      end
    end
  end
end
