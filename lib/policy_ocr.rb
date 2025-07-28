# frozen_string_literal: true

require "interactor"
require "pry"
require "yaml"

# Use the PolicyOcr parent namespace to encapsulate shared constants, avoid "magic strings"
# and generally act as a config would.
module PolicyOcr
  DIGITS_PER_LINE = 9.freeze
  DIGIT_WIDTH = 3.freeze
  LINE_HEIGHT = 4.freeze
  CARRIAGE_RETURN = "\n".freeze
  DIGITAL_INTS_CONFIG_PATH = "./lib/policy_ocr/digital_int/digital_ints.yml".freeze
end

# Load root level files first
require_relative "validate_policy_number"

# Load base classes first
require_relative "policy_ocr/digital_int/base"
require_relative "policy_ocr/digital_int/invalid"
require_relative "policy_ocr/digital_int"

# Load policy namespace files
require_relative "policy_ocr/policy/number"
require_relative "policy_ocr/policy/document"

# Load parse namespace files
require_relative "policy_ocr/parser/parse_policy_document"
require_relative "policy_ocr/parser/parse_policy_document_lines"
require_relative "policy_ocr/parser/parse_policy_number"

PolicyOcr::DigitalInt.load_all

result = PolicyOcr::Parser::ParsePolicyDocument.call(file_path: "./spec/fixtures/policy_numbers.txt")
if result.success?
  puts result.policy_document
else
  puts "Failed to read the file: #{result.error}"
end
