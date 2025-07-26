class PolicyOcr::DigitalInt::Zero < PolicyOcr::DigitalInt
  def self.pattern
    " _ " +
    "| |" +
    "|_|" +
    "   "
  end

  def to_i = 0
end