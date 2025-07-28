# frozen_string_literal: true
#
# This class represents a single parsed policy number as an array of DigitalChar objects.
#
module PolicyOcr
  module Policy
    class Number
      attr_reader :digital_ints

      def initialize(digital_ints)
        @digital_ints = digital_ints
      end

      def valid?
        return false if digital_ints.empty?

        digital_ints.all?(&:valid?)
      end

      def to_s
        digital_ints.map(&:to_s).join
      end
    end
  end
end
