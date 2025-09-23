#!/usr/bin/env ruby
# frozen_string_literal: true

require "thor"
require_relative "../policy_ocr"

module PolicyOcr
  class Cli < Thor
    def self.exit_on_failure?
      true
    end

    # Command aliases
    map "gen" => :generate_policy_numbers

    desc "parse FILE", "Parse policy numbers from an OCR text file"
    def parse(file_path)
      PolicyOcr.setup_logging_for_file(file_path)
      result = PolicyOcr::Parser::ParsePolicyDocumentFile.call(file_path:)

      if result.success?
        write_result = PolicyOcr::Cli::WriteOutputFile.call(
          content: result.policy_document.to_s,
          input_file: file_path
        )
        output_file = write_result.output_file if write_result.success?
      else
        PolicyOcr::Cli::PrintReport.call(result:, input_file: file_path, output_file: nil)
        exit 1
      end

      PolicyOcr::Cli::PrintReport.call(result:, input_file: file_path, output_file:)
    rescue StandardError => e
      puts "Error parsing file: #{e.message}"
      exit 1
    end

    desc "generate_policy_numbers", "Generate test policy numbers in ASCII digital format"
    option :valid_count, type: :numeric, default: 20, desc: "Number of valid policy numbers to generate (default: 20)"
    option :invalid_digits_count, type: :numeric, default: 6,
                                  desc: "Number of policy numbers with invalid digits (default: 6)"
    option :invalid_checksum_count, type: :numeric, default: 4,
                                    desc: "Number of policy numbers with checksum errors (default: 4)"
    option :unparseable_count, type: :numeric, default: 0,
                               desc: "Number of unparseable patterns to generate (default: 0)"
    def generate_policy_numbers
      PolicyOcr::Cli::GenerateSamplePolicyNumbers.call(
        valid_count: options[:valid_count],
        invalid_digits_count: options[:invalid_digits_count],
        invalid_checksum_count: options[:invalid_checksum_count],
        unparseable_count: options[:unparseable_count]
      )
    end
  end
end

# Load CLI interactors after Cli class is defined
require_relative "cli/print_report"
require_relative "cli/generate_sample_policy_numbers"
require_relative "cli/write_output_file"

# Run the CLI if this file is executed directly
PolicyOcr::Cli.start(ARGV) if __FILE__ == $PROGRAM_NAME
