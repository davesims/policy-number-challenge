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
    def parse(file_path)
      PolicyOcr.setup_logging_for_file(file_path)
      result = PolicyOcr::Parser::ParsePolicyDocumentFile.call(file_path:)

      if result.failure?
        PolicyOcr::Cli::PrintReport.call(result:, input_file: file_path, output_file: nil)
        return exit 1
      end

      write_result = PolicyOcr::Cli::WriteOutputFile.call(
        content: result.policy_document.to_s,
        input_file: file_path
      )
      output_file = write_result.output_file if write_result.success?

      PolicyOcr::Cli::PrintReport.call(result:, input_file: file_path, output_file:)
    rescue StandardError => e
      puts "Error parsing file: #{e.message}"
      exit 1
    end

    desc "generate_policy_numbers", "Generate test policy numbers in ASCII digital format"
    def generate_policy_numbers
      result = PolicyOcr::Cli::GenerateSamplePolicyNumbers.call
      puts result.generated_numbers
    end
  end
end

# Load CLI interactors after Cli class is defined
require_relative "cli/print_report"
require_relative "cli/generate_sample_policy_numbers"
require_relative "cli/write_output_file"

# Run the CLI if this file is executed directly
PolicyOcr::Cli.start(ARGV) if __FILE__ == $PROGRAM_NAME
