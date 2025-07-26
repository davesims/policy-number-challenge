class PolicyOcr::DigitalInt::One < PolicyOcr::DigitalInt
  def self.pattern
    "   " +
    "  |" +
    "  |" +
    "   "
  end

  def to_i = 1
end