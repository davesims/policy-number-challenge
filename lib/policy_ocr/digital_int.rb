# frozen_string_literal: true

module PolicyOcr
  module DigitalInt
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
      return PolicyOcr::DigitalInt::Invalid.new(pattern: "?") unless valid_int?(int)

      klass = all_numbers[int]
      klass.new
    end

    def self.valid_int?(int)
      int.is_a?(Integer) && int.between?(0, 9)
    end

    def self.logger
      PolicyOcr.logger_for(self)
    end
  end
end
