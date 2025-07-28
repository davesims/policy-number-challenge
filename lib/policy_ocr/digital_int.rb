class PolicyOcr::DigitalInt
  attr_reader :int_value
  alias_method :to_i, :int_value

  def self.all_numbers
    [Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine]
  end

  def self.from_pattern(pattern)
    klass = all_numbers.find { |k| k::PATTERN == pattern }

    if klass.nil?
      PolicyOcr::DigitalInt::Invalid.new(pattern:)
    end

    klass.new
  end

  def pattern
    self.class::PATTERN
  end

  def to_s
    int_value.to_s
  end

  def print_pattern
    puts pattern
          .chars
          .each_slice(3)
          .map(&:join)
          .join("\n")
  end
end

