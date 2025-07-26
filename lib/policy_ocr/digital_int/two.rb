class PolicyOcr::DigitalInt::Two < PolicyOcr::DigitalInt
  def self.pattern
    " _ " +
    " _|" +
    "|_ " +
    "   "
  end

  def to_i = 2
end