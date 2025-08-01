# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class Nine < Base
      def self.pattern
        " _ " +
        "|_|" +
        " _|"
      end

      def initialize
        @int_value = 9
      end
    end
  end
end