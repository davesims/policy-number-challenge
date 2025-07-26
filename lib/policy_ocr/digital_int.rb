class PolicyOcr::DigitalInt
  def self.all_numbers
    [Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine]
  end

  def self.from_string(digital_pattern)
    klass = all_numbers.find { |number_klass| number_klass.pattern == digital_pattern }
    klass&.new
  end

  def self.pattern
    raise NotImplementedError, "This method should be implemented in subclasses"
  end

  def to_i
    raise NotImplementedError, "This method should be implemented in subclasses"
  end

  def self.print_pattern
    puts pattern.chars.each_slice(3).map { |slice| slice.join }.join("\n")
  end

  def print_pattern
    self.class.print_pattern
  end
end

