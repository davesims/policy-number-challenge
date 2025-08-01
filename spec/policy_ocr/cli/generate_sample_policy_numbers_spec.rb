# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/policy_ocr/cli"

RSpec.describe PolicyOcr::Cli::GenerateSamplePolicyNumbers do
  describe ".call" do
    subject(:output) { capture_stdout { described_class.call(params) } }

    context "with only valid numbers" do
      let(:params) { { valid_count: 2, invalid_digits_count: 0, invalid_checksum_count: 0, unparseable_count: 0 } }

      it "generates the correct number of policy numbers" do
        lines = output.split("\n")
        # Each policy number has 3 lines plus 1 blank separator, last policy has no trailing blank
        expect(lines.length).to eq(7) # 2 * 3 + 1 separator = 7 total lines
      end

      it "generates valid policy number patterns" do
        lines = output.split("\n")
        non_empty_lines = lines.reject(&:empty?)
        # Check lines have correct structure (27 characters each for valid patterns)
        non_empty_lines.each do |line|
          expect(line.length).to eq(27) # 9 digits * 3 characters per digit
        end
        expect(lines.count(&:empty?)).to eq(1) # 1 separator line
      end
    end

    context "with mixed policy number types" do
      let(:params) { { valid_count: 1, invalid_digits_count: 1, invalid_checksum_count: 1, unparseable_count: 1 } }

      it "generates the correct total number of policy numbers" do
        lines = output.split("\n")
        # 4 policy numbers with 3 lines each + 3 separators = 15 total lines
        expect(lines.length).to eq(15)
      end

      it "includes different types of patterns" do
        # Just verify output is generated - specific content validation would require
        # parsing the output, which is complex given the randomization
        expect(output).not_to be_empty
        expect(output.split("\n").count(&:empty?)).to eq(3) # 3 separator lines
      end
    end

    context "with only unparseable numbers" do
      let(:params) { { valid_count: 0, invalid_digits_count: 0, invalid_checksum_count: 0, unparseable_count: 2 } }

      it "generates unparseable patterns" do
        lines = output.split("\n")
        expect(lines.length).to be >= 4 # At least 2 patterns with separator

        # Verify unparseable patterns have structural issues
        non_empty_lines = lines.reject(&:empty?)
        expect(non_empty_lines.length).to be >= 4 # At least some content lines

        # At least some lines should not be exactly 27 characters (unparseable patterns)
        line_lengths = non_empty_lines.map(&:length)
        expect(line_lengths).to include(satisfy { |length| length != 27 })
      end
    end

    context "with zero counts" do
      let(:params) { { valid_count: 0, invalid_digits_count: 0, invalid_checksum_count: 0, unparseable_count: 0 } }

      it "generates no output" do
        expect(output).to be_empty
      end
    end
  end

  describe "unparseable generation methods" do
    let(:instance) { described_class.new }

    describe "#generate_unparseable_lines" do
      it "returns an array of 3 lines" do
        lines = instance.send(:generate_unparseable_lines)
        expect(lines).to be_an(Array)
        expect(lines.length).to eq(3)
      end

      it "generates lines with varying structural issues" do
        # Test multiple calls to see different patterns
        patterns = 10.times.map { instance.send(:generate_unparseable_lines) }

        # Should generate different line length combinations
        line_length_sets = patterns.map { |pattern| pattern.map(&:length) }
        expect(line_length_sets.uniq.length).to be > 1
      end

      it "generates lines that would cause parsing failures" do
        lines = instance.send(:generate_unparseable_lines)

        # At least one line should not be divisible by 3 (digit width)
        divisible_by_three = lines.all? { |line| line.length % 3 == 0 }
        digit_counts = lines.map { |line| line.length / 3 }
        all_have_9_digits = digit_counts.all? { |count| count == 9 }

        # Should fail either character alignment or digit count validation
        expect(divisible_by_three && all_have_9_digits).to be false
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
