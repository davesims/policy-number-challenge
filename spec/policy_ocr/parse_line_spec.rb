require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyDocumentText do
  describe ".call" do
    let(:context) { build(:read_lines_context) }
    
    it "successfully processes raw text into policy numbers" do
      result = PolicyOcr::Parser::ParsePolicyDocumentText.call(context)
      
      expect(result).to be_success
      expect(result.all_policy_numbers).to be_an(Array)
    end
    
    it "calls ParsePolicyNumberLine for each line group" do
      expect(PolicyOcr::Parser::ParsePolicyNumberLine).to receive(:call).at_least(:once).and_call_original
      
      PolicyOcr::Parser::ParsePolicyDocumentText.call(context)
    end
    
    it "splits text by carriage return and groups by LINE_HEIGHT" do
      raw_text = "line1\nline2\nline3\nline4\nline5\nline6\nline7\nline8"
      context = build(:read_lines_context, raw_text: raw_text)
      
      result = PolicyOcr::Parser::ParsePolicyDocumentText.call(context)
      
      # Should create 2 groups of 4 lines each
      expect(result.all_policy_numbers.size).to eq(2)
    end
  end
  
end