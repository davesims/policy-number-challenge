# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class Zero < Base
      def self.pattern
        " _ " +
        "| |" +
        "|_|"
      end

      def initialize
        @int_value = 0
      end
    end
  end
end
