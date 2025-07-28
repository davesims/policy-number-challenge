class PolicyOcr::DigitalInt::Zero < PolicyOcr::DigitalInt
  PATTERN = " _ " +
            "| |" +
            "|_|" +
            "   "

  def initialize
    @int_value = 0
  end
end
