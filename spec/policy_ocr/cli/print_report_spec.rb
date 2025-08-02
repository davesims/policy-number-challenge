# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/policy_ocr/cli"

RSpec.describe PolicyOcr::Cli::PrintReport do
  let(:policy_document) { instance_double(PolicyOcr::Policy::Document) }
  let(:success_result) { double(success?: true, policy_document:, parser_errors: []) }
  let(:input_file) { "test.txt" }
  let(:result) { success_result }
  let(:output_file) { "parsed_files/sample_parsed.txt" }

  before do
    PolicyOcr.current_log_path = "test.log"
  end

  describe "validations" do
    subject(:print_report_result) { described_class.call({ result:, input_file:, output_file: }) }

    context "without result" do
      let(:result) { nil }

      it "fails" do
        expect(print_report_result.success?).to be false
        expect(print_report_result.error).to include("result")
      end
    end

    context "without input_file" do
      let(:input_file) { nil }

      it "fails" do
        expect(print_report_result.success?).to be false
        expect(print_report_result.error).to include("input_file")
      end
    end

    context "when success case is missing output_file" do
      let(:output_file) { nil }

      it "fails when success case is missing output_file" do
        expect(print_report_result.success?).to be false
        expect(print_report_result.error).to include("output_file")
      end
    end
  end

  describe "success case output" do
    subject(:output) { capture_stdout { described_class.call({ result:, input_file:, output_file: }) } }

    before do
      allow(policy_document).to receive_messages(total_count: 10, valid_count: 7, err_count: 2, ill_count: 1,
                                                 unparseable_count: 0)
    end

    it "displays success header" do
      expect(output).to include(/✅ SUCCESSFULLY PARSED test.txt/)
    end

    context "when displaying file information" do
      it "displays input file" do
        expect(output).to include("📄 Input File: test.txt")
      end

      it "displays output file" do
        expect(output).to include("📝 Output File: parsed_files/sample_parsed.txt")
      end

      it "displays log file" do
        expect(output).to include("📋 Log File: test.log")
      end
    end

    context "when displaying parsing statistics" do
      it "displays header" do
        expect(output).to include("📈 PARSING STATISTICS:")
      end

      it "displays total count" do
        expect(output).to include("Total Lines Parsed: 10")
      end

      it "displays valid numbers count" do
        expect(output).to include("✅ Valid Numbers: 7")
      end

      it "displays checksum errors count" do
        expect(output).to include("❌ Invalid Checksum (ERR): 2")
      end

      it "displays invalid digits count" do
        expect(output).to include("❓ Invalid Digits (ILL): 1")
      end

      it "displays unparseable count" do
        expect(output).to include("🚫 Unparseable: 0")
      end

      it "displays success footer" do
        expect(output).to include(/✨ Parsing completed successfully!/)
      end
    end

    context "with non-zero unparseable count" do
      before do
        allow(policy_document).to receive_messages(total_count: 5, valid_count: 2, err_count: 1, ill_count: 1,
                                                   unparseable_count: 1)
      end

      it "displays unparseable count without ILL label" do
        expect(output).to include("🚫 Unparseable: 1")
        expect(output).not_to include("🚫 Unparseable (ILL)")
      end
    end

    context "with parser errors" do
      let(:result) { double(success?: true, policy_document:, parser_errors: ["Error 1", "Error 2"]) }

      it "displays warning header" do
        expect(output).to include(/⚠️  PARSED test.txt WITH ERRORS/)
      end

      context "when displaying parser errors section" do
        it "displays parser errors header" do
          expect(output).to include("⚠️  PARSER ERRORS ENCOUNTERED:")
        end

        it "displays a parser error" do
          expect(output).to include("  1. Error 1")
        end

        it "displays another parser error" do
          expect(output).to include("  2. Error 2")
        end
      end
    end

    describe "error case output" do
      let(:result) { double(success?: false, error: "Failed to parse policy document: raw_text cannot be empty") }
      let(:output_file) { nil }

      it "displays error header" do
        expect(output).to include(/❌ UNABLE TO PARSE test.txt/)
      end

      context "when displaying error details" do
        it "displays error message" do
          expect(output).to include("❌ Error: Failed to parse policy document: raw_text cannot be empty")
        end

        it "displays file prompt" do
          expect(output).to include("💡 Please check that the file exists and contains valid policy number data.")
        end

        it "displays log file prompt" do
          expect(output).to include("💡 Check the log file for detailed error information.")
        end
      end

      it "does not display success footer" do
        expect(output).not_to include("✨ Parsing completed successfully!")
      end
    end
  end

  private

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
