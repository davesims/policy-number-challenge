# frozen_string_literal: true

require 'English'
require "spec_helper"
require "tempfile"
require_relative "../../lib/policy_ocr/cli"

RSpec.describe PolicyOcr::Cli do
  subject(:output) { `policy_ocr parse #{file_path}` }

  let(:file_path) { "spec/fixtures/sample.txt" }
  let(:exit_code) { $CHILD_STATUS.exitstatus }
  let(:line_matcher) { /^\d{9} $|^\d{9} ERR$|^\d*\?+\d* ILL$|\?{9} ILL$|^123456789$/ }

  def run_parse_command(file_path)
    output = `policy_ocr parse #{file_path}`

    {
      output: output,
      exit_code: $CHILD_STATUS.exitstatus
    }
  end

  describe "#parse" do
    context "with valid policy numbers" do
      let(:lines) { subject.strip.split("\n") }

      it "displays a formatted parsing report" do
        expect(output).to include("✅ SUCCESSFULLY PARSED sample.txt")
        expect(output).to include("Input File: spec/fixtures/sample.txt")
        expect(output).to include("Output File: parsed_files/sample_parsed.txt")
        expect(output).to include("Log File: parsed_files/parsed_sample.log")
        expect(output).to include("Total Lines Parsed: 11")
        expect(output).to include("Valid Numbers: 2")
        expect(output).to include("Checksum Errors (ERR): 9")
        expect(output).to include("Invalid Digits (ILL): 0")
        expect(output).to include("Parsing completed successfully!")
        expect(exit_code).to eq(0)
      end

      let(:output_file) { "parsed_files/sample_parsed.txt" }
      let(:log_file) { "parsed_files/parsed_sample.log" }

      before do
        File.delete(output_file) if File.exist?(output_file)
        File.delete(log_file) if File.exist?(log_file)
      end

      after do
        File.delete(output_file) if File.exist?(output_file)
        File.delete(log_file) if File.exist?(log_file)
      end

      it "creates output file with correct name and content" do
        # Run the command
        subject
        
        # Check file was created
        expect(File.exist?(output_file)).to be true
        
        # Check file content matches expected policy numbers
        file_content = File.read(output_file)
        expect(file_content).to include("000000000 ")
        expect(file_content).to include("123456789 ")
        expect(file_content).to include("111111111 ERR")
        
        # Check output includes file reference
        expect(output).to include("Output File: #{output_file}")
      end
    end

    context "with invalid digits" do
      let(:file_path) { "spec/fixtures/invalid_digits.txt" }

      it "reports invalid digits in parsing statistics" do
        expect(output).to include("PARSED invalid_digits.txt WITH ERRORS")
        expect(output).to include("Invalid Digits (ILL):")
        expect(exit_code).to eq(0)
      end
    end

    context "with checksum errors" do
      let(:file_path) { "spec/fixtures/checksum_errors.txt" }

      it "reports checksum errors in parsing statistics" do
        expect(output).to include("✅ SUCCESSFULLY PARSED checksum_errors.txt")
        expect(output).to include("Checksum Errors (ERR):")
        expect(exit_code).to eq(0)
      end
    end

    context "with mixed scenarios" do
      let(:file_path) { "spec/fixtures/mixed_policy_numbers.txt" }
      let(:output_file) { "parsed_files/mixed_policy_numbers_parsed.txt" }
      let(:log_file) { "parsed_files/parsed_mixed_policy_numbers.log" }

      before do
        File.delete(output_file) if File.exist?(output_file)
        File.delete(log_file) if File.exist?(log_file)
      end

      after do
        File.delete(output_file) if File.exist?(output_file)
        File.delete(log_file) if File.exist?(log_file)
      end

      it "handles combination of valid, invalid digits, and checksum errors" do
        expect(output).to include(" ")
        expect(output).to include("ERR")
        expect(output).to include("ILL")
        expect(exit_code).to eq(0)
      end

      it "creates output file with correct filename based on input" do
        # Run the command
        subject
        
        # Check file was created with correct name
        expect(File.exist?(output_file)).to be true
        expect(output).to include("Output File: #{output_file}")
      end
    end
  end

  describe "error handling scenarios" do
    context "when file does not exist" do
      let(:file_path) { "nonexistent_file.txt" }

      it "displays error message and exits with code 1" do
        expect(output).to include("Error: File 'nonexistent_file.txt' not found")
        expect(exit_code).to eq(1)
      end
    end

    context "when file exists but is empty" do
      let(:file_path) { "spec/fixtures/empty.txt" }

      it "handles empty files gracefully" do
        expect(output).to include("❌ UNABLE TO PARSE empty.txt")
        expect(output).to include("Error: Failed to parse policy document: raw_text cannot be empty")
      end
    end

    context "when file has malformed content" do
      let(:file_path) { "spec/fixtures/malformed_content.txt" }

      it "handles files with incorrect line counts" do
        expect(output).to include("Malformed number line at 3: element size differs (7 should be 10)")
        expect(output).to include("Malformed number line at 3: element size differs (7 should be 10)")
        expect(output).to include("Malformed number line")
      end
    end
  end
end
