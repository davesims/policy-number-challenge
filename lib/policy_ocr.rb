# frozen_string_literal: true

require "interactor"
require "pry"
require "yaml"
require "logger"

# Use the PolicyOcr parent namespace to encapsulate shared constants, avoid "magic strings"
# and generally act as a config would.
module PolicyOcr
  DIGITS_PER_LINE = 9
  DIGIT_WIDTH = 3
  LINE_HEIGHT = 3
  CARRIAGE_RETURN = "\n"
  LOG_PATH = "policy_ocr.log"
  PARSED_FILES_DIR = "parsed_files"

  def self.current_log_path
    Thread.current[:policy_ocr_log_path] || LOG_PATH
  end

  def self.current_log_path=(path)
    Thread.current[:policy_ocr_log_path] = path
  end

  def self.setup_logging_for_file(input_file)
    log_path = generate_log_file_path(input_file)
    self.current_log_path = log_path
    log_path
  end

  def self.generate_log_file_path(input_file)
    log_dir = "log"
    FileUtils.mkdir_p(log_dir)

    base_name = File.basename(input_file, ".*")
    File.join(log_dir, "#{base_name}_parsed.log")
  end

  def self.logger_for(klass)
    Logger.new(current_log_path).tap do |log|
      log.level = Logger::DEBUG
      log.formatter = proc do |severity, datetime, _progname, msg|
        full_name = klass.respond_to?(:name) ? klass.name : klass.class.name
        "[#{full_name} #{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
      end
    end
  end
end

# I've been preferring explicit requires to Dir/glob, as it makes the dependencies clearer
# and avoids potential load order issues.

# Load root level files first
require_relative "interactor/validations"
require_relative "policy_ocr/validate_policy_number_checksum"

# Load base classes next
require_relative "policy_ocr/digital_int/base"
require_relative "policy_ocr/digital_int/invalid"
require_relative "policy_ocr/digital_int"

# Load policy namespace files
require_relative "policy_ocr/policy/number"
require_relative "policy_ocr/policy/document"

# Load parse namespace files
require_relative "policy_ocr/parser/parse_policy_document_file"
require_relative "policy_ocr/parser/parse_policy_document_text"
require_relative "policy_ocr/parser/parse_policy_number_line"

# Load all digit class definitions
require_relative "policy_ocr/digital_int/zero"
require_relative "policy_ocr/digital_int/one"
require_relative "policy_ocr/digital_int/two"
require_relative "policy_ocr/digital_int/three"
require_relative "policy_ocr/digital_int/four"
require_relative "policy_ocr/digital_int/five"
require_relative "policy_ocr/digital_int/six"
require_relative "policy_ocr/digital_int/seven"
require_relative "policy_ocr/digital_int/eight"
require_relative "policy_ocr/digital_int/nine"

