require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyDocumentFile do
  describe ".call" do
    let(:context) { build(:policy_ocr_context) }
    
    context "with valid inputs" do
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

    context "with invalid inputs" do
      it "fails when file_path is nil" do
        result = PolicyOcr::Parser::ParsePolicyDocumentFile.call(file_path: nil)
        
        expect(result).to be_failure
        expect(result.error).to eq("file_path is required")
      end

      it "fails when file_path is empty" do
        result = PolicyOcr::Parser::ParsePolicyDocumentFile.call(file_path: "")
        
        expect(result).to be_failure
        expect(result.error).to eq("file_path cannot be empty")
      end

      it "fails when file_path is blank" do
        result = PolicyOcr::Parser::ParsePolicyDocumentFile.call(file_path: "   ")
        
        expect(result).to be_failure
        expect(result.error).to eq("file_path cannot be blank")
      end

      it "fails when file does not exist" do
        result = PolicyOcr::Parser::ParsePolicyDocumentFile.call(file_path: "nonexistent.txt")
        
        expect(result).to be_failure
        expect(result.error).to include("No such file or directory")
      end
    end
  end
end