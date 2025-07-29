require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyDocumentFile do
  describe ".call" do
    let(:context) { build(:policy_ocr_context) }
    subject { described_class.call(context) }
    
    context "with valid inputs" do
      it "successfully processes file into policy document" do
        expect(subject).to be_success
        expect(subject.policy_document).to be_a(PolicyOcr::Policy::Document)
      end
      
      it "calls ParsePolicyDocumentText" do
        expect(PolicyOcr::Parser::ParsePolicyDocumentText).to receive(:call).and_call_original
        subject
      end
      
      it "reads file and processes into policy document" do
        expect(subject.policy_document.policy_numbers).to be_an(Array)
      end
    end

    context "with invalid inputs" do
      describe "when file_path is nil" do 
        let(:context) { build(:policy_ocr_context, file_path: nil) }
        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("file_path is required")
        end
      end

      describe "when file_path is empty" do 
        let(:context) { build(:policy_ocr_context, file_path: "") }
        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("file_path cannot be empty")
        end
      end

      describe "when file does not exist" do 
        let(:context) { build(:policy_ocr_context, file_path: "nonexistent.txt") }
        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("No such file or directory @ rb_sysopen - nonexistent.txt")
        end
      end
    end
  end
end
