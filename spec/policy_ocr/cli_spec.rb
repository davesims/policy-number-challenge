# frozen_string_literal: true

require_relative "../../lib/policy_ocr/cli"

require "spec_helper"

RSpec.describe PolicyOcr::Cli do
  let(:cli) { described_class.new }
  let(:file_path) { "spec/fixtures/sample.txt" }

  before do
    allow(PolicyOcr).to receive(:setup_logging_for_file)
    allow(PolicyOcr::Cli::PrintReport).to receive(:call)
    allow(Kernel).to receive(:exit).and_raise(SystemExit)
  end

  describe "#parse" do
    subject(:parse_file) { cli.parse(file_path) }

    let(:policy_document) { instance_double(PolicyOcr::Policy::Document, to_s: "parsed content") }
    let(:parse_result) do
      build(:interactor_context, success?: true, policy_document:, parser_errors: [])
    end
    let(:write_result) do
      build(:interactor_context, success?: true, output_file: "path/to/output.txt")
    end

    before do
      allow(PolicyOcr::Parser::ParsePolicyDocumentFile).to receive(:call).and_return(parse_result)
      allow(PolicyOcr::Cli::WriteOutputFile).to receive(:call).and_return(write_result)
    end

    it "sets up logging for the input file" do
      expect(PolicyOcr).to receive(:setup_logging_for_file).with(file_path)
      parse_file
    end

    it "calls the ParsePolicyDocumentFile interactor with the correct file path" do
      expect(PolicyOcr::Parser::ParsePolicyDocumentFile).to receive(:call).with(file_path:)
      parse_file
    end

    context "when parsing is successful" do
      it "calls the WriteOutputFile interactor" do
        expect(PolicyOcr::Cli::WriteOutputFile).to receive(:call).with(
          content: policy_document.to_s,
          input_file: file_path
        )
        parse_file
      end

      it "calls the PrintReport interactor with the success result" do
        expect(PolicyOcr::Cli::PrintReport).to receive(:call).with(
          result: parse_result,
          input_file: file_path,
          output_file: write_result.output_file
        )
        parse_file
      end

      it "does not exit with an error code" do
        parse_file
      end
    end

    context "when parsing fails" do
      let(:parse_result) do
        build(:failed_interactor_context, error: "Parsing failed")
      end

      before do
        allow(PolicyOcr::Cli::WriteOutputFile).to receive(:call)
      end

      it "does not call the WriteOutputFile interactor" do
        expect(PolicyOcr::Cli::WriteOutputFile).not_to receive(:call)
        expect { parse_file }.to raise_error(SystemExit)
      end

      it "calls the PrintReport interactor with the failure result" do
        expect(PolicyOcr::Cli::PrintReport).to receive(:call).with(
          result: parse_result,
          input_file: file_path,
          output_file: nil
        )
        expect { parse_file }.to raise_error(SystemExit)
      end
    end

    context "when an unexpected error occurs" do
      let(:error) { StandardError.new("Something went wrong") }

      before do
        allow(PolicyOcr::Parser::ParsePolicyDocumentFile).to receive(:call).and_raise(error)
        allow($stdout).to receive(:puts) # Suppress output for cleaner test logs
      end

      it "prints an error message" do
        expect($stdout).to receive(:puts).with("Error parsing file: Something went wrong")
        expect { parse_file }.to raise_error(SystemExit)
      end
    end
  end

  describe "#generate_policy_numbers" do
    subject(:generate_policy_numbers) { cli.generate_policy_numbers }

    let(:generator_result) do
      build(:interactor_context, success?: true, generated_numbers: "sample numbers")
    end

    before do
      allow(PolicyOcr::Cli::GenerateSamplePolicyNumbers).to receive(:call).and_return(generator_result)
      allow($stdout).to receive(:puts)
    end

    it "calls the GenerateSamplePolicyNumbers interactor" do
      expect(PolicyOcr::Cli::GenerateSamplePolicyNumbers).to receive(:call)
      generate_policy_numbers
    end

    it "prints the generated numbers to stdout" do
      expect($stdout).to receive(:puts).with("sample numbers")
      generate_policy_numbers
    end
  end
end
