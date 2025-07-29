require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyDocumentText do
  describe ".call" do
    let(:context) { build(:read_lines_context, raw_text: raw_text) }
    let(:raw_text) { "line1\nline2\nline3\nline4\nline5\nline6\nline7\nline8" }
    let(:subject) { PolicyOcr::Parser::ParsePolicyDocumentText.call(context) }
    
    context "with valid inputs" do
      it "successfully processes raw text into policy numbers" do
        expect(subject).to be_success
        expect(subject.policy_numbers).to be_an(Array)
      end
      
      it "calls ParsePolicyNumberLine for each line group" do
        expect(PolicyOcr::Parser::ParsePolicyNumberLine).to receive(:call).at_least(:once).and_call_original
        subject
      end
      
      it "splits text by carriage return and groups by LINE_HEIGHT" do
        expect(subject.policy_numbers.size).to eq(2)
      end
    end

    context "with invalid inputs" do

      describe "when raw_text is nil" do
        let(:raw_text) { nil }
        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("raw_text is required")
        end
      end

      describe "when raw_text is empty" do
        let(:raw_text) { "" }
        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("raw_text cannot be empty")
        end
      end

      describe "when raw_text is blank" do
        let(:raw_text) { "   \n\t  " }
        it "fails" do
          expect(subject).to be_failure
          expect(subject.error).to eq("raw_text cannot be blank")
        end
      end
    end
  end
  
end
