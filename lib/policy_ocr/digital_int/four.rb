class PolicyOcr::DigitalInt::Four < PolicyOcr::DigitalInt
  PATTERN = "   " +
            "|_|" +
            "  |" +
            "   "

  def initialize
    @int_value = 4
  end
end