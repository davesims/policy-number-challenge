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

      def valid?
        return false if digital_ints.empty?

        digital_ints.all?(&:valid?)
      end

      def checksum?
        PolicyOcr::ValidatePolicyNumberChecksum.call(policy_number: self).success?
      end

      def to_s
        "#{digital_ints.map(&:to_s).join} #{message}"
      end

      def to_a
        digital_ints.map(&:int_value)
      end

      def message
        return INVALID_DIGITS_MESSAGE unless valid?
        return CHECKSUM_ERROR_MESSAGE unless checksum?
        ""
      end

      class Invalid < Number
        def initialize
          digital_ints = Array.new(9, PolicyOcr::DigitalInt::Invalid.new(pattern: "---"))
          super(digital_ints)
        end
      end
    end
  end
end
