# frozen_string_literal: true

require 'interactor'
require 'pry'

# Use the PolicyOcr parent namespace to encapsulate shared constants, avoid "magic strings"
# and generally act as a config would.
module PolicyOcr
  DIGITS_PER_LINE = 9.freeze
  DIGIT_WIDTH = 3.freeze
  LINE_HEIGHT = 4.freeze
  CARRIAGE_RETURN = "\n".freeze
end

# Load root level files first
require_relative 'validate_policy_number'

# Load base classes first
require_relative 'policy_ocr/digital_int'

# Load policy namespace files
require_relative 'policy_ocr/policy/number'
require_relative 'policy_ocr/policy/document'

# Load parse namespace files
require_relative 'policy_ocr/parse/policy_document'
require_relative 'policy_ocr/parse/policy_document_line'
require_relative 'policy_ocr/parse/policy_number'

# Load digit classes after base class
require_relative 'policy_ocr/digital_int/zero'
require_relative 'policy_ocr/digital_int/one'
require_relative 'policy_ocr/digital_int/two'
require_relative 'policy_ocr/digital_int/three'
require_relative 'policy_ocr/digital_int/four'
require_relative 'policy_ocr/digital_int/five'
require_relative 'policy_ocr/digital_int/six'
require_relative 'policy_ocr/digital_int/seven'
require_relative 'policy_ocr/digital_int/eight'
require_relative 'policy_ocr/digital_int/nine'
require_relative 'policy_ocr/digital_int/invalid'



result = PolicyOcr::Parse::PolicyDocument.call(file_path: './spec/fixtures/sample.txt')
if result.success?
  puts "Successfully read the file."
  puts "Numbers: #{result.inpect}"
else
  puts "Failed to read the file: #{result.error}"
end
