class PolicyOcr::DigitalInt::Seven < PolicyOcr::DigitalInt
  def self.pattern
    " _ " +
    "  |" +
    "  |" +
    "   "
  end

  def to_i = 7
end