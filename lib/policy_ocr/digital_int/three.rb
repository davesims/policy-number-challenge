class PolicyOcr::DigitalInt::Three < PolicyOcr::DigitalInt
  def self.pattern
    " _ " +
    " _|" +
    " _|" +
    "   "
  end

  def to_i = 3
end