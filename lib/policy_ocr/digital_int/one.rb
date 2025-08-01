# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class One < Base
      def self.pattern
        "   " +
        "  |" +
        "  |"
      end

      def initialize
        @int_value = 1
      end
    end
  end
end