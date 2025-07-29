require "spec_helper"

RSpec.describe PolicyOcr do
  describe "parsing policy documents" do
    let(:context) { build(:policy_ocr_context) }
    
    context "when file exists" do
      it "successfully reads and processes the file" do
        result = PolicyOcr::Parser::ParsePolicyDocumentFile.call(context)
        
        expect(result).to be_success
        expect(result.policy_document).to be_a(PolicyOcr::Policy::Document)
      end
      
      it "calls ParsePolicyDocumentText" do
        expect(PolicyOcr::Parser::ParsePolicyDocumentText).to receive(:call).and_call_original
        
        PolicyOcr::Parser::ParsePolicyDocumentFile.call(context)
      end
    end
    
    context "when file does not exist" do
      let(:context) { build(:policy_ocr_context, file_path: "nonexistent.txt") }
      
      it "fails with error message" do
        expect {
          PolicyOcr::Parser::ParsePolicyDocumentFile.call(context)
        }.to raise_error(Errno::ENOENT)
      end
    end
  end
  
  describe "constants" do
    it "defines expected constants" do
      expect(PolicyOcr::DIGITS_PER_LINE).to eq(9)
      expect(PolicyOcr::DIGIT_WIDTH).to eq(3)
      expect(PolicyOcr::LINE_HEIGHT).to eq(4)
    end
  end
end