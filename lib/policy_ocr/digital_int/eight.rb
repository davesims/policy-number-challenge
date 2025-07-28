class PolicyOcr::DigitalInt::Eight < PolicyOcr::DigitalInt
  PATTERN = " _ " +
            "|_|" +
            "|_|" +
            "   "

  def initialize
    @int_value = 8
  end
end
