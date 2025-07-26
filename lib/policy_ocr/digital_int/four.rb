class PolicyOcr::DigitalInt::Four < PolicyOcr::DigitalInt
  def self.pattern
    "   " +
    "|_|" +
    "  |" +
    "   "
  end

  def to_i = 4
end