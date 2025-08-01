# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class Four < Base
      def self.pattern
        "   " +
        "|_|" +
        "  |"
      end

      def initialize
        @int_value = 4
      end
    end
  end
end
