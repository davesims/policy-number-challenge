module PolicyOcr::DigitalInt
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
