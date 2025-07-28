class PolicyOcr::DigitalInt::Nine < PolicyOcr::DigitalInt
  PATTERN = " _ " +
            "|_|" +
            " _|" +
            "   "

  def initialize
    @int_value = 9
  end
end