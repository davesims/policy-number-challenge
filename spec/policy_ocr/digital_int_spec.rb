# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyOcr::DigitalInt do
  # rubocop:disable Metrics/MethodLength, Style/StringConcatenation, Style/LineEndConcatenation, Layout/MultilineOperationIndentation
  let(:pattern) do
    " _ " +
    "| |" +
    "|_|"
  end

  let(:digit) { described_class.from_pattern(pattern) }

  def self.expected_patterns
    {
      PolicyOcr::DigitalInt::Zero => " _ " +
                                     "| |" +
                                     "|_|",

      PolicyOcr::DigitalInt::One => "   " +
                                    "  |" +
                                    "  |",

      PolicyOcr::DigitalInt::Two => " _ " +
                                    " _|" +
                                    "|_ ",

      PolicyOcr::DigitalInt::Three => " _ " +
                                      " _|" +
                                      " _|",

      PolicyOcr::DigitalInt::Four => "   " +
                                     "|_|" +
                                     "  |",

      PolicyOcr::DigitalInt::Five => " _ " +
                                     "|_ " +
                                     " _|",

      PolicyOcr::DigitalInt::Six => " _ " +
                                    "|_ " +
                                    "|_|",

      PolicyOcr::DigitalInt::Seven => " _ " +
                                      "  |" +
                                      "  |",

      PolicyOcr::DigitalInt::Eight => " _ " +
                                      "|_|" +
                                      "|_|",

      PolicyOcr::DigitalInt::Nine => " _ " +
                                     "|_|" +
                                     " _|"
    }
  end

  # rubocop:enable Metrics/MethodLength, Style/StringConcatenation, Style/LineEndConcatenation, Layout/MultilineOperationIndentation

  describe ".all_numbers" do
    it "returns all digit classes" do
      expect(described_class.all_numbers).to eq([
                                                  Zero, One, Two,
                                                  Three, Four, Five,
                                                  Six, Seven, Eight,
                                                  Nine
                                                ])
    end
  end

  describe ".from_pattern" do
    it "returns correct digit instance for valid pattern" do
      expect(digit).to be_a(PolicyOcr::DigitalInt::Zero)
      expect(digit.to_i).to eq(0)
    end

    context "with an invalid pattern" do
      let(:pattern) { "xxx" }

      it "returns Invalid instance for invalid pattern" do
        expect(digit).to be_a(PolicyOcr::DigitalInt::Invalid)
      end
    end
  end

  describe "digit classes" do
    expected_patterns.each do |digit_class, expected_pattern|
      digit_value = digit_class.name.split("::").last.downcase
      expected_int = %w[zero one two three four five six seven eight nine].index(digit_value)

      describe digit_class do
        describe ".pattern" do
          it "returns correct ASCII art pattern" do
            expect(digit_class.pattern).to eq(expected_pattern)
          end
        end

        describe "#to_i" do
          it "returns #{expected_int}" do
            expect(digit_class.new.to_i).to eq(expected_int)
          end
        end

        describe "#pattern" do
          it "returns the same as class pattern" do
            instance = digit_class.new
            expect(instance.pattern).to eq(digit_class.pattern)
          end
        end

        describe "#valid?" do
          it "returns true" do
            expect(digit_class.new.valid?).to be true
          end
        end

        describe "#to_s" do
          it "returns string representation of integer value" do
            expect(digit_class.new.to_s).to eq(expected_int.to_s)
          end
        end
      end
    end
  end
end
