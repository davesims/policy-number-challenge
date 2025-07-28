class PolicyOcr::DigitalInt::Six < PolicyOcr::DigitalInt  
  PATTERN = " _ " +
            "|_ " +
            "|_|" +
            "   "

  def initialize
    @int_value = 6
  end
end