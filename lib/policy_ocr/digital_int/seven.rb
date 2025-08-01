# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class Seven < Base
      def self.pattern
        " _ " +
        "  |" +
        "  |"
      end

      def initialize
        @int_value = 7
      end
    end
  end
end