# frozen_string_literal: true

require 'English'
require "spec_helper"
require "tempfile"
require_relative "../../lib/policy_ocr/cli"

RSpec.describe PolicyOcr::Cli do
  subject(:cli_output) { `./policy_ocr parse #{file_path}` }

  let(:file_path) { "spec/fixtures/sample.txt" }
  let(:exit_code) { $CHILD_STATUS.exitstatus }

  describe "#parse" do
    context "with valid policy numbers" do
      let(:output_file) { "parsed_files/sample_parsed.txt" }
      let(:log_file) { "log/sample_parsed.log" }

      before do
        FileUtils.rm_f(output_file)
        FileUtils.rm_f(log_file)
      end

      after do
        FileUtils.rm_f(output_file)
        FileUtils.rm_f(log_file)
      end

      it "processes file successfully and creates output file" do
        cli_output

        # Check files were created
        expect(File.exist?(output_file)).to be true
        expect(File.exist?(log_file)).to be true

        # Check file content has parsed policy numbers
        file_content = File.read(output_file)
        expect(file_content).to include("000000000 ")
        expect(file_content).to include("123456789 ")
        expect(file_content).to include("111111111 ERR")

        # Check exit code
        expect(exit_code).to eq(0)
      end
    end
  end

  describe "#generate_policy_numbers" do
    subject(:generate_output) { `./policy_ocr generate_policy_numbers #{options}` }

    let(:exit_code) { $CHILD_STATUS.exitstatus }

    context "with unparseable_count option" do
      let(:options) { "--valid-count=1 --invalid-digits-count=1 --invalid-checksum-count=1 --unparseable-count=2" }

      it "generates mixed policy number types including unparseable" do
        expect(generate_output).not_to be_empty
        expect(exit_code).to eq(0)

        lines = generate_output.split("\n")
        # Should be at least 12 lines (4 policies * 3 lines each) plus separators
        expect(lines.length).to be >= 15

        # Should have at least 3 blank separator lines
        blank_lines = lines.count(&:empty?)
        expect(blank_lines).to be >= 3

        # At least some lines should be unparseable (not exactly 27 characters)
        content_lines = lines.reject(&:empty?)
        line_lengths = content_lines.map(&:length)
        expect(line_lengths).to include(satisfy { |length| length != 27 })
      end
    end

    context "with only unparseable_count" do
      let(:options) { "--valid-count=0 --invalid-digits-count=0 --invalid-checksum-count=0 --unparseable-count=3" }

      it "generates only unparseable patterns" do
        expect(generate_output).not_to be_empty
        expect(exit_code).to eq(0)

        lines = generate_output.split("\n")
        # Should have at least some content lines
        expect(lines.length).to be >= 6

        # Should have at least 2 blank separator lines
        blank_lines = lines.count(&:empty?)
        expect(blank_lines).to be >= 2

        # At least some lines should be unparseable (not exactly 27 characters)
        content_lines = lines.reject(&:empty?)
        line_lengths = content_lines.map(&:length)
        expect(line_lengths).to include(satisfy { |length| length != 27 })
      end
    end

    context "with zero unparseable_count" do
      let(:options) { "--valid-count=2 --invalid-digits-count=0 --invalid-checksum-count=0 --unparseable-count=0" }

      it "generates no unparseable patterns" do
        expect(generate_output).not_to be_empty
        expect(exit_code).to eq(0)

        lines = generate_output.split("\n")
        content_lines = lines.reject(&:empty?)

        # All content lines should be exactly 27 characters (parseable)
        line_lengths = content_lines.map(&:length)
        expect(line_lengths.all? { |length| length == 27 }).to be true
      end
    end

    context "with default options" do
      let(:options) { "" }

      it "uses default counts including zero unparseable" do
        expect(generate_output).not_to be_empty
        expect(exit_code).to eq(0)

        # Default is valid_count=20, invalid_digits_count=6, invalid_checksum_count=4, unparseable_count=0
        # Total: 30 policy numbers
        lines = generate_output.split("\n")
        expect(lines.length).to be >= 90 # At least 30 policies * 3 lines each

        # Should have 29 blank separator lines
        blank_lines = lines.count(&:empty?)
        expect(blank_lines).to eq(29)
      end
    end
  end

  describe "error handling scenarios" do
    context "when file does not exist" do
      let(:file_path) { "nonexistent_file.txt" }

      it "displays error message and exits with code 1" do
        expect(cli_output).to include("Error: File 'nonexistent_file.txt' not found")
        expect(exit_code).to eq(1)
      end
    end

    context "when file exists but is empty" do
      let(:file_path) { "spec/fixtures/empty.txt" }

      it "handles empty files gracefully" do
        expect(cli_output).to include("Error: Failed to parse policy document: raw_text cannot be empty")
      end
    end

    context "when file has malformed content" do
      let(:file_path) { "spec/fixtures/malformed_content.txt" }

      it "handles files with incorrect line counts" do
        expect(cli_output).to include("Line 4: Each line must be exactly 27 characters")
        expect(cli_output).to include("This is not valid OCR content")
        expect(cli_output).to include("Just some random text")
        expect(cli_output).to include("That should not parse correctly")
      end
    end
  end
end
