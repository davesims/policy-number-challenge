class PolicyOcr::DigitalInt::Nine < PolicyOcr::DigitalInt
  def self.pattern
    " _ " +
    "|_|" +
    " _|" +
    "   "
  end

  def to_i = 9
end