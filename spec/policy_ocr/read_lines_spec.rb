require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyDocumentFile do
  describe ".call" do
    let(:context) { build(:policy_ocr_context) }
    
    it "successfully processes file into policy document" do
      result = PolicyOcr::Parser::ParsePolicyDocumentFile.call(context)
      
      expect(result).to be_success
      expect(result.policy_document).to be_a(PolicyOcr::Policy::Document)
    end
    
    it "calls ParsePolicyDocumentText" do
      expect(PolicyOcr::Parser::ParsePolicyDocumentText).to receive(:call).and_call_original
      
      PolicyOcr::Parser::ParsePolicyDocumentFile.call(context)
    end
    
    it "reads file and processes into policy document" do
      result = PolicyOcr::Parser::ParsePolicyDocumentFile.call(context)
      
      expect(result.policy_document.policy_numbers).to be_an(Array)
    end
  end
end