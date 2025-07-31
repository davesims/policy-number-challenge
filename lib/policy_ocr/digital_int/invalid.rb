# frozen_string_literal: true

module PolicyOcr::DigitalInt
  # This class represents an invalid digital pattern encountered while parsing a policy number.
  # It serves as a place-holder in the PolicyDocument until error correction is applied. 
  #
  class Invalid < Base
    attr_reader :pattern

    def initialize(pattern:)
      @pattern = pattern
      @int_value = nil
    end

    def pattern
      @pattern
    end

    def valid?
      false
    end

    def to_s
      "?"
    end
  end
end
