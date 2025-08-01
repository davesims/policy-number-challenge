# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr::Policy::Number::Unparseable do
  describe "#initialize" do
    context "with no arguments" do
      subject(:unparseable) { described_class.new }

      it "creates default unparseable lines" do
        expect(unparseable.number_lines).to eq([
                                                 "???????????????????????????",
                                                 "???????????????????????????",
                                                 "???????????????????????????"
                                               ])
      end

      it "creates digital_ints with Invalid pattern" do
        expect(unparseable.digital_ints.size).to eq(9)
        expect(unparseable.digital_ints.all? { |di| di.is_a?(PolicyOcr::DigitalInt::Invalid) }).to be true
      end
    end

    context "with custom number_lines" do
      subject(:unparseable) { described_class.new(custom_lines) }

      let(:custom_lines) { %w[line1 line2 line3] }

      it "uses the provided number_lines" do
        expect(unparseable.number_lines).to eq(custom_lines)
      end
    end
  end

  describe "#unparseable?" do
    subject(:unparseable) { described_class.new }

    it "returns true" do
      expect(unparseable.unparseable?).to be true
    end
  end

  describe "#to_s" do
    subject(:unparseable) { described_class.new }

    it "returns the unparseable format" do
      expect(unparseable.to_s).to eq("????????? ILL")
    end
  end

  describe "#print_pattern" do
    subject(:unparseable) { described_class.new(custom_lines) }

    let(:custom_lines) { %w[line1 line2 line3] }

    it "prints the number_lines joined with CARRIAGE_RETURN plus blank line" do
      expect { unparseable.print_pattern }.to output("line1\nline2\nline3\n\n").to_stdout
    end
  end
end
