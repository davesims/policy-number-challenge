# frozen_string_literal: true

require 'English'
require "spec_helper"
require "tempfile"
require_relative "../../lib/policy_ocr/cli"

RSpec.describe PolicyOcr::Cli do
  subject(:cli_output) { `policy_ocr parse #{file_path}` }

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
        expect(cli_output).to include("❌ UNABLE TO PARSE empty.txt")
        expect(cli_output).to include("Error: Failed to parse policy document: raw_text cannot be empty")
      end
    end

    context "when file has malformed content" do
      let(:file_path) { "spec/fixtures/malformed_content.txt" }

      it "handles files with incorrect line counts" do
        expect(cli_output).to include("Malformed number line at 3: element size differs (7 should be 10)")
        expect(cli_output).to include("Malformed number line at 3: element size differs (7 should be 10)")
        expect(cli_output).to include("Malformed number line")
      end
    end
  end
end
