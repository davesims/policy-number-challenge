# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyNumberLine do
  describe ".call" do
    subject(:result) { described_class.call(context) }

    let(:context) { build(:policy_number_line_context, index:) }
    let(:index) { 0 }

    context "with valid inputs" do
      it "successfully processes number line into policy number" do
        expect(result).to be_success
        expect(result.policy_number).to be_a(PolicyOcr::Policy::Number)
      end

      it "creates digital ints from patterns" do
        expect(result.policy_number.digital_ints.size).to eq(9)
        expect(result.policy_number.digital_ints.first).to respond_to(:pattern)
      end
    end

    context "with invalid inputs" do
      context "when number_line is nil" do
        let(:context) { build(:policy_number_line_context, number_line: nil) }

        it "fails and sets Unparseable policy number" do
          expect(result).to be_failure
          expect(result.error).to eq("number_line is required")
          expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Unparseable)
        end
      end

      context "when number_line is empty" do
        let(:context) { build(:policy_number_line_context, number_line: []) }

        it "fails and sets Unparseable policy number" do
          expect(result).to be_failure
          expect(result.error).to eq("number_line cannot be empty")
          expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Unparseable)
        end
      end

      context "when number_line has wrong size" do
        let(:context) { build(:policy_number_line_context, number_line: %w[line1 line2], index:) }

        it "fails and sets Unparseable policy number" do
          expect(result).to be_failure
          expect(result.error).to eq("number_line must have exactly #{PolicyOcr::LINE_HEIGHT} elements")
          expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Unparseable)
        end
      end

      context "when number_line has too many lines" do
        let(:context) do
          build(:policy_number_line_context, number_line: %w[line1 line2 line3 line4 line5], index:)
        end

        it "fails and sets Unparseable policy number" do
          expect(result).to be_failure
          expect(result.error).to eq("number_line must have exactly #{PolicyOcr::LINE_HEIGHT} elements")
          expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Unparseable)
        end
      end

      context "when the index is missing" do
        let(:context) { build(:policy_number_line_context) }

        it "fails and sets Unparseable policy number" do
          expect(result).to be_failure
          expect(result.error).to eq("index is required")
          expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Unparseable)
        end
      end
    end

    context "with structural validation failures" do
      context "when lines are not divisible by 3 characters" do
        let(:context) { build(:policy_number_line_context, number_line: %w[X ABC DEFGH], index: 2) }

        it "fails with line length error and shows offending lines" do
          expect(result).to be_failure
          expect(result.error).to include("Line 3: Each line must be exactly 27 characters")
          expect(result.error).to include("9 digits × 3 characters per digit")
          expect(result.error).to include("  X")
          expect(result.error).to include("  ABC")
          expect(result.error).to include("  DEFGH")
          expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Unparseable)
        end
      end

      context "when lines don't have exactly 9 digits" do
        let(:context) do
          build(:policy_number_line_context,
                number_line: ["", "ABCDEFGHIJKLMNOPQRSTUVWXYZ1", "ABCDEFGHIJKLMNOPQRSTUVWXYZ2"],
                index: 5)
        end

        it "fails with line length error and shows offending lines" do
          expect(result).to be_failure
          expect(result.error).to include("Line 6: Each line must be exactly 27 characters")
          expect(result.error).to include("9 digits × 3 characters per digit")
          expect(result.error).to include("  ") # empty line with spaces
          expect(result.error).to include("  ABCDEFGHIJKLMNOPQRSTUVWXYZ1")
          expect(result.error).to include("  ABCDEFGHIJKLMNOPQRSTUVWXYZ2")
          expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Unparseable)
        end
      end

      context "when lines have mixed structural issues" do
        let(:context) { build(:policy_number_line_context, number_line: %w[AB TOOLONG X], index: 0) }

        it "fails with line length validation error" do
          expect(result).to be_failure
          expect(result.error).to include("Line 1: Each line must be exactly 27 characters")
          expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Unparseable)
        end
      end
    end

    context "when StandardError occurs during parsing" do
      context "when the line is malformed" do
        let(:malformed_line) { %w[invalid data here] }
        let(:context) { build(:policy_number_line_context, number_line: malformed_line, index:) }

        it "returns Unparseable policy number and fails context" do
          expect(result).to be_failure
          expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Unparseable)
          expect(result.error).to include("Line 1:")
          expect(result.error).to include("  invalid")
          expect(result.error).to include("  data")
          expect(result.error).to include("  here")
        end
      end

      context "when digital patterns are malformed" do
        let(:lines_with_different_lengths) { ["short", "this is a much longer line that will cause issues", "med"] }
        let(:context) { build(:policy_number_line_context, number_line: lines_with_different_lengths, index: 1) }

        it "handles errors gracefully" do
          expect(result).to be_failure
          expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Unparseable)
          expect(result.error).to include("Line 2:")
        end
      end
    end

    describe "error formatting methods" do
      let(:test_context) { build(:policy_number_line_context, number_line: %w[AB DEFGHIJKLM NO], index: 3) }
      let(:instance) { described_class.new }

      before do
        # Initialize the interactor with the context using call_with_context helper
        instance.instance_variable_set(:@context, test_context)
      end

      describe "#format_offending_lines" do
        it "formats lines with simple indentation" do
          formatted = instance.send(:format_offending_lines)
          expect(formatted).to include("  AB")
          expect(formatted).to include("  DEFGHIJKLM")
          expect(formatted).to include("  NO")
        end
      end

      describe "#line_length_error_message" do
        it "includes line number and formatted offending lines" do
          message = instance.send(:line_length_error_message, 27)
          expect(message).to include("Line 4: Each line must be exactly 27 characters")
          expect(message).to include("9 digits × 3 characters per digit")
          expect(message).to include("  AB")
          expect(message).to include("  DEFGHIJKLM")
          expect(message).to end_with("\n")
        end
      end
    end
  end
end
