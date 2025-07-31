# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr::Parser::ParsePolicyDocumentText do
  describe ".call" do
    subject(:result) { described_class.call(context) }

    let(:context) { build(:read_lines_context, raw_text: raw_text) }
    let(:raw_text) { "line1\nline2\nline3\nline4\nline5\nline6\nline7\nline8" }

    context "with valid inputs" do
      it "successfully processes raw text into policy numbers" do
        expect(result).to be_success
        expect(result.policy_numbers).to be_an(Array)
      end

      it "calls ParsePolicyNumberLine for each line group" do
        expect(PolicyOcr::Parser::ParsePolicyNumberLine).to receive(:call).at_least(:once).and_call_original
        result
      end

      it "splits text by carriage return and groups by LINE_HEIGHT" do
        expect(result.policy_numbers.size).to eq(2)
      end
    end

    context "with invalid inputs" do
      context "when raw_text is nil" do
        let(:raw_text) { nil }

        it "fails" do
          expect(result).to be_failure
          expect(result.error).to eq("raw_text is required")
        end
      end

      context "when raw_text is empty" do
        let(:raw_text) { "" }

        it "fails" do
          expect(result).to be_failure
          expect(result.error).to eq("raw_text cannot be empty")
        end
      end

      context "when raw_text is blank" do
        let(:raw_text) { "   \n\t  " }

        it "fails" do
          expect(result).to be_failure
          expect(result.error).to eq("raw_text cannot be blank")
        end
      end

      context "when raw_text has incomplete lines (validation failures)" do
        # This creates 5 lines total, which after removing every 4th line leaves 4 lines
        # 4 lines / 3 LINE_HEIGHT = 1 complete group + 1 incomplete group with only 1 line
        let(:raw_text) { "line1\nline2\nline3\n\nline5" }

        it "processes complete groups and records validation errors for incomplete groups" do
          expect(result).to be_success
          expect(result.policy_numbers.size).to eq(2)
          expect(result.policy_numbers.last).to be_a(PolicyOcr::Policy::Number::Invalid)
          expect(result.parser_errors).not_to be_empty
          expect(result.parser_errors).to include(match(/number_line must have exactly 3 elements/))
        end
      end
    end
  end
end
