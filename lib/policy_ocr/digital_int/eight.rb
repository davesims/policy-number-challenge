# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class Eight < Base
      def self.pattern
        " _ " +
        "|_|" +
        "|_|"
      end

      def initialize
        @int_value = 8
      end
    end
  end
end
