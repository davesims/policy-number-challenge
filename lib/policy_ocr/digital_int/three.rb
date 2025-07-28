class PolicyOcr::DigitalInt::Three < PolicyOcr::DigitalInt
  PATTERN = " _ " +
            " _|" +
            " _|" +
            "   "

  def initialize
    @int_value = 3
  end
end