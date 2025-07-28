require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyDocumentLines do
  describe ".call" do
    let(:context) { build(:read_lines_context) }
    
    it "successfully processes raw text into policy numbers" do
      result = PolicyOcr::Parser::ParsePolicyDocumentLines.call(context)
      
      expect(result).to be_success
      expect(result.all_policy_numbers).to be_an(Array)
    end
    
    it "calls ParsePolicyNumber for each line group" do
      expect(PolicyOcr::Parser::ParsePolicyNumber).to receive(:call).at_least(:once).and_call_original
      
      PolicyOcr::Parser::ParsePolicyDocumentLines.call(context)
    end
    
    it "splits text by carriage return and groups by LINE_HEIGHT" do
      raw_text = "line1\nline2\nline3\nline4\nline5\nline6\nline7\nline8"
      context = build(:read_lines_context, raw_text: raw_text)
      
      result = PolicyOcr::Parser::ParsePolicyDocumentLines.call(context)
      
      # Should create 2 groups of 4 lines each
      expect(result.all_policy_numbers.size).to eq(2)
    end
  end
  
  describe "private methods" do
    let(:context) { build(:read_lines_context) }
    let(:instance) { PolicyOcr::Parser::ParsePolicyDocumentLines.new(context) }
    
    describe "#lines" do
      it "splits raw text correctly" do
        lines = instance.send(:lines)
        
        expect(lines).to be_an(Array)
        expect(lines.first.size).to eq(PolicyOcr::LINE_HEIGHT)
      end
    end
    
    describe "#raw_text" do
      it "memoizes raw text from context" do
        expect(instance.send(:raw_text)).to eq(context.raw_text)
        expect(instance.send(:raw_text)).to be(instance.send(:raw_text)) # same object
      end
    end
  end
end