class PolicyOcr::DigitalInt::Eight < PolicyOcr::DigitalInt
  def self.pattern
    " _ " +
    "|_|" +
    "|_|" +
    "   "
  end

  def to_i = 8
end