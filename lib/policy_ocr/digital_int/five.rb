class PolicyOcr::DigitalInt::Five < PolicyOcr::DigitalInt
  def self.pattern
    " _ " +
    "|_ " +
    " _|" +
    "   "
  end

  def to_i = 5
end