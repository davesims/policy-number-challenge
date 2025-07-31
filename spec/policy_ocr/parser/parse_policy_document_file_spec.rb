# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyDocumentFile do
  describe ".call" do
    subject(:result) { described_class.call(context) }

    let(:context) { build(:policy_ocr_context) }

    context "with valid inputs" do
      it "successfully processes file into policy document" do
        expect(result).to be_success
        expect(result.policy_document).to be_a(PolicyOcr::Policy::Document)
      end

      it "calls ParsePolicyDocumentText" do
        expect(PolicyOcr::Parser::ParsePolicyDocumentText).to receive(:call).and_call_original
        result
      end

      it "reads file and processes into policy document" do
        expect(result.policy_document.policy_numbers).to be_an(Array)
      end
    end

    context "with invalid inputs" do
      context "when file_path is nil" do
        let(:context) { build(:policy_ocr_context, file_path: nil) }

        it "fails" do
          expect(result).to be_failure
          expect(result.error).to eq("file_path is required")
        end
      end

      context "when file_path is empty" do
        let(:context) { build(:policy_ocr_context, file_path: "") }

        it "fails" do
          expect(result).to be_failure
          expect(result.error).to eq("file_path cannot be empty")
        end
      end

      context "when file does not exist" do
        let(:context) { build(:policy_ocr_context, file_path: "nonexistent.txt") }

        it "fails" do
          expect(result).to be_failure
          expect(result.error).to eq("No such file or directory @ rb_sysopen - nonexistent.txt")
        end
      end
    end
  end
end
