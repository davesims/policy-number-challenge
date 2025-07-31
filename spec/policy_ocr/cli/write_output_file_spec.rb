# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/policy_ocr/cli"

RSpec.describe PolicyOcr::Cli::WriteOutputFile do
  let(:content) { "123456789 \n987654321 ERR\n????????? ILL" }
  let(:input_file) { "spec/fixtures/sample.txt" }
  let(:output_dir) { "test_output" }

  after do
    FileUtils.rm_rf("test_output")
    FileUtils.rm_rf("parsed_files")
  end

  describe "validations" do
    context "without content" do
      it "fails" do
        result = described_class.call(input_file:)

        expect(result.success?).to be false
        expect(result.error).to include("content")
      end
    end

    context "without input_file" do
      it "fails" do
        result = described_class.call(content:)

        expect(result.success?).to be false
        expect(result.error).to include("input_file")
      end
    end
  end

  describe "successful file writing" do
    subject(:result) { described_class.call(content:, input_file:) }

    context "with default output directory" do
      it "succeeds" do
        expect(result.success?).to be true
      end

      it "creates the default output directory" do
        result
        expect(Dir.exist?("parsed_files")).to be true
      end

      it "generates correct output filename" do
        result
        expect(result.output_file).to eq("parsed_files/sample_parsed.txt")
      end

      it "writes content to the output file" do
        result
        written_content = File.read(result.output_file)
        expect(written_content).to eq(content)
      end
    end

    context "with different input file extensions" do
      let(:input_file) { "data/policies.csv" }

      it "strips extension correctly" do
        result
        expect(result.output_file).to eq("parsed_files/policies_parsed.txt")
      end
    end

    context "with input file without extension" do
      let(:input_file) { "data/policies" }

      it "handles files without extension" do
        result
        expect(result.output_file).to eq("parsed_files/policies_parsed.txt")
      end
    end

    context "with nested input file path" do
      let(:input_file) { "nested/dir/sample.txt" }

      it "uses only the basename" do
        result
        expect(result.output_file).to eq("parsed_files/sample_parsed.txt")
      end
    end
  end

  describe "error handling" do
    context "when directory creation fails" do
      before do
        allow(FileUtils).to receive(:mkdir_p).and_raise(Errno::EACCES, "Permission denied")
      end

      it "fails gracefully" do
        expect { described_class.call(content:, input_file:) }.to raise_error(Errno::EACCES)
      end
    end

    context "when file writing fails" do
      before do
        allow(File).to receive(:write).and_raise(Errno::ENOSPC, "No space left on device")
      end

      it "fails gracefully" do
        expect { described_class.call(content:, input_file:) }.to raise_error(Errno::ENOSPC)
      end
    end
  end
end
