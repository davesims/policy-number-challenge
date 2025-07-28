class PolicyOcr::DigitalInt::One < PolicyOcr::DigitalInt
  PATTERN = "   " +
            "  |" +
            "  |" +
            "   "

  def initialize
    @int_value = 1
  end
end