class PolicyOcr::DigitalInt::Seven < PolicyOcr::DigitalInt
  PATTERN = " _ " +
            "  |" +
            "  |" +
            "   "

  def initialize
    @int_value = 7
  end
end