# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class Two < Base
      def self.pattern
        " _ " +
        " _|" +
        "|_ "
      end

      def initialize
        @int_value = 2
      end
    end
  end
end