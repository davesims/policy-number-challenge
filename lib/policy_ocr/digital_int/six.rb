# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class Six < Base
      def self.pattern
        " _ " +
        "|_ " +
        "|_|"
      end

      def initialize
        @int_value = 6
      end
    end
  end
end
