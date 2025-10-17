# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class Base
      attr_reader :int_value
      alias to_i int_value

      def pattern
        self.class.pattern
      end

      def to_s
        int_value.to_s
      end

      def valid?
        true
      end

      def adjacent_digits
        all_numbers.select do |num|
          num.pattern.chars.zip(pattern.chars).one? do |a, b|
            a != b && (a == " " || b == " ")
          end
        end
      end

      private

      def all_numbers = PolicyOcr::DigitalInt.all_numbers
    end
  end
end
