require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyNumberLine do
  describe ".call" do
    let(:context) { build(:policy_number_line_context, index:) }
    let(:index) { 0 }
    subject { described_class.call(context) }

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
      describe "when number_line is nil" do 
        let (:context) { build(:policy_number_line_context, number_line: nil) }

        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("number_line is required")
        end
      end

      describe "when number_line is empty" do 
        let (:context) { build(:policy_number_line_context, number_line: []) }

        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("number_line cannot be empty")
        end
      end

      describe "when number_line has wrong size" do
        let(:context) { build(:policy_number_line_context, number_line: ["line1", "line2"], index:) }

        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("number_line must have exactly #{PolicyOcr::LINE_HEIGHT} elements")
        end
      end

      describe "fails when number_line has wrong size (too many lines)" do
        let(:context) { build(:policy_number_line_context, number_line: ["line1", "line2", "line3", "line4", "line5"], index:) }
        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("number_line must have exactly #{PolicyOcr::LINE_HEIGHT} elements")
        end
      end

      describe "when the index is missing" do 
        let(:context) { build(:policy_number_line_context) }
        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("index is required")
        end
      end
    end

    context "when StandardError occurs during parsing" do
      it "returns Invalid policy number and fails context" do
        # Create invalid number_line that will cause parsing errors
        malformed_line = [
          "invalid", # This will cause issues when trying to parse digit patterns
          "data",
          "here",
          "test"
        ]
        
        result = PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line: malformed_line, index: 0)
        
        expect(result).to be_failure
        expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Invalid)
        expect(result.error).to include("Failed to parse policy number line:")
      end

      it "handles errors gracefully when digital patterns are malformed" do
        # Create lines that will pass validation but fail during digital pattern extraction
        lines_with_different_lengths = [
          "short",
          "this is a much longer line that will cause issues",
          "med",
          "x"
        ]
        
        result = PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line: lines_with_different_lengths, index: 1)
        
        expect(result).to be_failure
        expect(result.policy_number).to be_a(PolicyOcr::Policy::Number::Invalid)
        expect(result.error).to match(/Failed to parse policy number line:/)
      end
    end
  end
end
