#!/usr/bin/env ruby
# frozen_string_literal: true

require "thor"
require_relative "../policy_ocr"

module PolicyOcr
  class Cli < Thor
    def self.exit_on_failure?
      true
    end

    desc "parse FILE", "Parse policy numbers from an OCR text file"
    def parse(file)
      validate_file_exists(file)
      setup_logging(file)

      result = PolicyOcr::Parser::ParsePolicyDocumentFile.call(file_path: file)
      handle_parse_result(result, file)
    rescue StandardError => e
      handle_parsing_error(e)
    end

    desc "generate_policy_numbers", "Generate test policy numbers in ASCII digital format"
    def generate_policy_numbers
      result = PolicyOcr::Cli::GenerateSamplePolicyNumbers.call
      puts result.generated_numbers
    end

    private

    def validate_file_exists(file)
      return if File.exist?(file)

      puts "Error: File '#{file}' not found"
      exit 1
    end

    def handle_parse_result(result, input_file)
      output_file = nil

      if result.success?
        write_result = PolicyOcr::Cli::WriteOutputFile.call(
          content: result.policy_document.to_s,
          input_file:
        )
        output_file = write_result.output_file if write_result.success?
      end

      PolicyOcr::Cli::PrintReport.call(result:, input_file:, output_file:, log_file: log_file(input_file))

      exit 1 unless result.success?
    end

    def handle_parsing_error(error)
      puts "Error parsing file: #{error.message}"
      exit 1
    end

    def setup_logging(input_file)
      PolicyOcr.current_log_path = log_file(input_file)
    end

    def log_file(input_file)
      @log_files ||= {}
      @log_files[input_file] ||= begin
        log_dir = "log"
        FileUtils.mkdir_p(log_dir)

        base_name = File.basename(input_file, ".*")
        File.join(log_dir, "#{base_name}_parsed.log")
      end
    end
  end
end

# Load CLI interactors after Cli class is defined
require_relative "cli/print_report"
require_relative "cli/generate_sample_policy_numbers"
require_relative "cli/write_output_file"

# Run the CLI if this file is executed directly
PolicyOcr::Cli.start(ARGV) if __FILE__ == $PROGRAM_NAME
