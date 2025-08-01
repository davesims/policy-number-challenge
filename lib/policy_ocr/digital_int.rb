# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
    # Load all digit class definitions
    require_relative "digital_int/zero"
    require_relative "digital_int/one"
    require_relative "digital_int/two"
    require_relative "digital_int/three"
    require_relative "digital_int/four"
    require_relative "digital_int/five"
    require_relative "digital_int/six"
    require_relative "digital_int/seven"
    require_relative "digital_int/eight"
    require_relative "digital_int/nine"

    def self.all_numbers
      [Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine]
    end

    # Returns a new instance of the digital int class that matches the given pattern.
    # If no matching class is found, it returns an instance of Invalid with the given pattern.
    # @param pattern [String] The pattern to match against the digital int classes.
    def self.from_pattern(pattern)
      klass = all_numbers.find { |k| k.pattern == pattern }

      if klass.nil?
        logger.warn "Invalid pattern: #{pattern}. Returning Invalid instance."
        return PolicyOcr::DigitalInt::Invalid.new(pattern:)
      end

      klass.new
    end

    # Returns a new instance of the digital int class that matches the given integer.
    # If the integer is not between 0 and 9, it returns an instance of
    # Invalid with a default pattern.
    # @param int [Integer] The integer to match against the digital int classes.
    def self.from_int(int)
      unless int.between?(0, 9)
        logger.error "Invalid int value given: #{int}."
        return PolicyOcr::DigitalInt::Invalid.new(pattern: "?")
      end

      klass = all_numbers[int]
      klass.new
    end

    def self.logger
      PolicyOcr.logger_for(self)
    end
  end
end
