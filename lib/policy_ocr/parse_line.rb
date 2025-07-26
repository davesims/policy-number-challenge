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
    PolicyOcr::DIGITS_PER_LINE.times.map {|index| digit(index) }
  end

  # Collect the flattened 3x3 digit representation for the given index
  def digit(index) 
    digital_number_string = PolicyOcr::DIGIT_HEIGHT.times.map { |row| slices[row][index] }.join
    PolicyOcr::DigitalInt.from_string(digital_number_string)
  end

  def slices 
    line
      .map(&:chars)
      .map {|l| l.each_slice(PolicyOcr::DIGIT_WIDTH).to_a }
  end

  def line = @line ||= context.line
end
