# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr do
  describe "constants" do
    it "defines expected constants" do
      expect(PolicyOcr::DIGITS_PER_LINE).to eq(9)
      expect(PolicyOcr::DIGIT_WIDTH).to eq(3)
      expect(PolicyOcr::LINE_HEIGHT).to eq(3)
      expect(PolicyOcr::LOG_PATH).to eq("policy_ocr.log")
      expect(PolicyOcr::PARSED_FILES_DIR).to eq("parsed_files")
    end
  end

  describe "logging" do
    let(:log_dir) { "log" }
    let(:input_file) { "path/to/my_policy_file.txt" }
    let(:expected_log_path) { "#{log_dir}/my_policy_file_parsed.log" }

    before do
      FileUtils.rm_rf(log_dir)
      Thread.current[:policy_ocr_log_path] = nil
    end

    after do
      FileUtils.rm_rf(log_dir)
      Thread.current[:policy_ocr_log_path] = nil
    end

    describe ".generate_log_file_path" do
      it "creates the log directory if it does not exist" do
        described_class.generate_log_file_path(input_file)
        expect(File.directory?(log_dir)).to be true
      end

      it "returns the correctly formatted log file path" do
        path = described_class.generate_log_file_path(input_file)
        expect(path).to eq(expected_log_path)
      end
    end

    describe ".setup_logging_for_file" do
      it "returns the generated log path" do
        expect(described_class.setup_logging_for_file(input_file)).to eq(expected_log_path)
      end

      it "sets the log path on the current thread" do
        described_class.setup_logging_for_file(input_file)
        expect(Thread.current[:policy_ocr_log_path]).to eq(expected_log_path)
      end
    end

    describe ".current_log_path" do
      context "when a path has been set on the current thread" do
        it "returns the path" do
          Thread.current[:policy_ocr_log_path] = "custom.log"
          expect(described_class.current_log_path).to eq("custom.log")
        end
      end

      context "when no path has been set" do
        it "returns the default log path" do
          expect(described_class.current_log_path).to eq(PolicyOcr::LOG_PATH)
        end
      end
    end

    describe ".logger_for" do
      let(:test_class) { PolicyOcr::Cli }
      let(:logger) { described_class.logger_for(test_class) }

      it "returns a Logger instance" do
        expect(logger).to be_a(Logger)
      end

      it "configures the logger with the current log path" do
        described_class.setup_logging_for_file(input_file)
        expect(logger.instance_variable_get(:@logdev).filename).to eq(expected_log_path)
      end

      it "configures the logger with the correct log level" do
        expect(logger.level).to eq(Logger::DEBUG)
      end

      it "configures the logger with a custom formatter" do
        expect(logger.formatter).to be_a(Proc)
        # Test the formatter output
        time = Time.now
        formatted_log = logger.formatter.call("INFO", time, "test", "message")
        expect(formatted_log).to include("[#{test_class.name} ")
        expect(formatted_log).to include("INFO: message")
      end
    end
  end
end
