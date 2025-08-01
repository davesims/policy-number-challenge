# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    class Five < Base
      def self.pattern
        " _ " +
        "|_ " +
        " _|"
      end

      def initialize
        @int_value = 5
      end
    end
  end
end