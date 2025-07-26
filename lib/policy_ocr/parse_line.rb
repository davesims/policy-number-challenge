# frozen_string_literal: true

# This class is responsible for parsing a single line of digits from the OCR output.
# It extracts the digits from a 27-character wide line and returns them as an array of strings.
# Each string represents a digit in a flattened 3x3 format.
class PolicyOcr::ParseLine
  include Interactor

  def call
    context.digits = digits
  end

  # Returns an array of 9 strings that each represent the flattened 3x3 digit representations
  # extracted from the 27x3 line that was given in context.line
  def digits
    digital_number_strings.map do |digital_number_string|
      PolicyOcr::DigitalInt.from_string(digital_number_string)
    end
  end

  # First, each line in the file will become a 4 x 9 x 3 array of characters: 
  # 4: is the height of each digit
  # 9: is the number of digits in a line (this is set by the position of the carriage return)
  # 3: is the width of each digit
  #
  # Then transpose the array to group characters by digit, and join each to make the digit's pattern
  def digital_number_strings
    line
      .map(&:chars) # make a 4 x 9 array of characters
      .map {|l| l.each_slice(PolicyOcr::DIGIT_WIDTH).to_a } # now we have a 4 x 9 x 3 array of characters
      .transpose # transpose to get a 9 x 4 x 3 array of characters, so that each digit is grouped together
      .map(&:join) # join each digit's characters into a single string which is the pattern that can be matched to a digit class
  end

  def line = @line ||= context.line
end
