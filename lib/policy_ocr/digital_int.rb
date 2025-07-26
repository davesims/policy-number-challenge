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

  class Zero < PolicyOcr::DigitalInt
    def self.pattern
      " _ " +
      "| |" +
      "|_|" +
      "   "
    end

    def to_i = 0
  end

  class One < PolicyOcr::DigitalInt
    def self.pattern
      "   " +
      "  |" +
      "  |" +
      "   "
    end

    def to_i = 1
  end

  class Two < PolicyOcr::DigitalInt
    def self.pattern
      " _ " +
      " _|" +
      "|_ " +
      "   "
    end

    def to_i = 2
  end

  class Three < PolicyOcr::DigitalInt
    def self.pattern
      " _ " +
      " _|" +
      " _|" +
      "   "
    end

    def to_i = 3
  end

  class Four < PolicyOcr::DigitalInt
    def self.pattern
      "   " +
      "|_|" +
      "  |" +
      "   "
    end

    def to_i = 4
  end

  class Five < PolicyOcr::DigitalInt
    def self.pattern
      " _ " +
      "|_ " +
      " _|" +
      "   "
    end

    def to_i = 5
  end

  class Six < PolicyOcr::DigitalInt
    def self.pattern
      " _ " +
      "|_ " +
      "|_|" +
      "   "
    end

    def to_i = 6
  end

  class Seven < PolicyOcr::DigitalInt
    def self.pattern
      " _ " +
      "  |" +
      "  |" +
      "   "
    end

    def to_i = 7
  end

  class Eight < PolicyOcr::DigitalInt
    def self.pattern
      " _ " +
      "|_|" +
      "|_|" +
      "   "
    end

    def to_i = 8
  end

  class Nine < PolicyOcr::DigitalInt
    def self.pattern
      " _ " +
      "|_|" +
      " _|" +
      "   "
    end

    def to_i = 9
  end
end
