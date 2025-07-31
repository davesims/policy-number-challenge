# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyNumberLine do
  describe ".call" do
    subject { described_class.call(context) }

    let(:context) { build(:policy_number_line_context, index:) }
    let(:index) { 0 }

    context "with valid inputs" do
      it "successfully processes number line into policy number" do
        expect(subject).to be_success
        expect(subject.policy_number).to be_a(PolicyOcr::Policy::Number)
      end

      it "creates digital ints from patterns" do
        expect(subject.policy_number.digital_ints.size).to eq(9)
        expect(subject.policy_number.digital_ints.first).to respond_to(:pattern)
      end
    end

    context "with invalid inputs" do
      context "when number_line is nil" do
        let(:context) { build(:policy_number_line_context, number_line: nil) }

        it "fails and sets Invalid policy number" do
          expect(subject).to be_failure
          expect(subject.error).to eq("number_line is required")
          expect(subject.policy_number).to be_a(PolicyOcr::Policy::Number::Invalid)
        end
      end

      context "when number_line is empty" do
        let(:context) { build(:policy_number_line_context, number_line: []) }

        it "fails and sets Invalid policy number" do
          expect(subject).to be_failure
          expect(subject.error).to eq("number_line cannot be empty")
          expect(subject.policy_number).to be_a(PolicyOcr::Policy::Number::Invalid)
        end
      end

      context "when number_line has wrong size" do
        let(:context) { build(:policy_number_line_context, number_line: %w[line1 line2], index:) }

        it "fails and sets Invalid policy number" do
          expect(subject).to be_failure
          expect(subject.error).to eq("number_line must have exactly #{PolicyOcr::LINE_HEIGHT} elements")
          expect(subject.policy_number).to be_a(PolicyOcr::Policy::Number::Invalid)
        end
      end

      context "fails when number_line has wrong size (too many lines)" do
        let(:context) do
          build(:policy_number_line_context, number_line: %w[line1 line2 line3 line4 line5], index:)
        end

        it "fails and sets Invalid policy number" do
          expect(subject).to be_failure
          expect(subject.error).to eq("number_line must have exactly #{PolicyOcr::LINE_HEIGHT} elements")
          expect(subject.policy_number).to be_a(PolicyOcr::Policy::Number::Invalid)
        end
      end

      context "when the index is missing" do
        let(:context) { build(:policy_number_line_context) }

        it "fails and sets Invalid policy number" do
          expect(subject).to be_failure
          expect(subject.error).to eq("index is required")
          expect(subject.policy_number).to be_a(PolicyOcr::Policy::Number::Invalid)
        end
      end
    end

    context "when StandardError occurs during parsing" do
      context "when the line is malformed" do
        let(:malformed_line) { %w[invalid data here] }
        let(:context) { build(:policy_number_line_context, number_line: malformed_line, index:) }

        it "returns Invalid policy number and fails context" do
          expect(subject).to be_failure
          expect(subject.policy_number).to be_a(PolicyOcr::Policy::Number::Invalid)
          expect(subject.error).to include("Malformed number line at #{index}")
        end
      end

      context "when digital patterns are malformed" do
        let(:lines_with_different_lengths) { ["short", "this is a much longer line that will cause issues", "med"] }
        let(:context) { build(:policy_number_line_context, number_line: lines_with_different_lengths, index: 1) }

        it "handles errors gracefully" do
          expect(subject).to be_failure
          expect(subject.policy_number).to be_a(PolicyOcr::Policy::Number::Invalid)
          expect(subject.error).to include("Malformed number line")
        end
      end
    end
  end
end
