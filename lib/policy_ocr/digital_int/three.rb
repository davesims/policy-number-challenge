# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class Three < Base
      def self.pattern
        " _ " +
        " _|" +
        " _|"
      end

      def initialize
        @int_value = 3
      end
    end
  end
end