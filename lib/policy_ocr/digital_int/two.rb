class PolicyOcr::DigitalInt::Two < PolicyOcr::DigitalInt
  PATTERN = " _ " +
            " _|" +
            "|_ " +
            "   "

  def initialize
    @int_value = 2
  end
end