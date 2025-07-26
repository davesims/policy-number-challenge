class PolicyOcr::DigitalInt::Six < PolicyOcr::DigitalInt
  def self.pattern
    " _ " +
    "|_ " +
    "|_|" +
    "   "
  end

  def to_i = 6
end