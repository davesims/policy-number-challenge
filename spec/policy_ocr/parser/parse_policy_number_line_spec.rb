require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyNumberLine do
  describe ".call" do
    let(:valid_number_line) do
      [
        " _  _  _  _  _  _  _  _  _ ",
        "| || || || || || || || || |",
        "|_||_||_||_||_||_||_||_||_|",
        "                         "
      ]
    end
    
    context "with valid inputs" do
      it "successfully processes number line into policy number" do
        result = PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line: valid_number_line, index: 0)
        
        expect(result).to be_success
        expect(result.policy_number).to be_a(PolicyOcr::Policy::Number)
      end
      
      it "creates digital ints from patterns" do
        result = PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line: valid_number_line, index: 1)
        
        expect(result.policy_number.digital_ints.size).to eq(9)
        expect(result.policy_number.digital_ints.first).to respond_to(:pattern)
      end
    end

    context "with invalid inputs" do
      it "fails when number_line is nil" do
        result = PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line: nil)
        
        expect(result).to be_failure
        expect(result.error).to eq("number_line is required")
      end

      it "fails when number_line is empty array" do
        result = PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line: [])
        
        expect(result).to be_failure
        expect(result.error).to eq("number_line cannot be empty")
      end

      it "fails when number_line has wrong size (too few lines)" do
        result = PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line: ["line1", "line2"], index: 0)
        
        expect(result).to be_failure
        expect(result.error).to eq("number_line must have exactly #{PolicyOcr::LINE_HEIGHT} elements")
      end

      it "fails when number_line has wrong size (too many lines)" do
        result = PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line: ["line1", "line2", "line3", "line4", "line5"], index: 0)
        
        expect(result).to be_failure
        expect(result.error).to eq("number_line must have exactly #{PolicyOcr::LINE_HEIGHT} elements")
      end

      it "fails when index is missing" do
        result = PolicyOcr::Parser::ParsePolicyNumberLine.call(number_line: valid_number_line)
        
        expect(result).to be_failure
        expect(result.error).to eq("index is required")
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