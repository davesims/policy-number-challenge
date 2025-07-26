require 'spec_helper'

RSpec.describe PolicyOcr::ParseLine do
  describe '.call' do
    let(:context) { build(:parse_line_context) }
    
    it 'successfully processes line into digits' do
      result = PolicyOcr::ParseLine.call(context)
      
      expect(result).to be_success
      expect(result.digits).to be_an(Array)
      expect(result.digits.size).to eq(PolicyOcr::DIGITS_PER_LINE)
    end
    
    it 'converts digital patterns to DigitalInt instances' do
      result = PolicyOcr::ParseLine.call(context)
      
      result.digits.each do |digit|
        expect(digit).to be_a(PolicyOcr::DigitalInt)
      end
    end
    
    it 'handles zero patterns correctly' do
      # Create a line with all zeros
      zero_line = [
        " _  _  _  _  _  _  _  _  _ ",
        "| || || || || || || || || |",
        "|_||_||_||_||_||_||_||_||_|",
        "                           "
      ]
      
      context = build(:parse_line_context, line: zero_line)
      result = PolicyOcr::ParseLine.call(context)
      
      expect(result.digits.map(&:to_i)).to eq([0] * 9)
    end
  end
  
  describe 'private methods' do
    let(:context) { build(:parse_line_context) }
    let(:instance) { PolicyOcr::ParseLine.new(context) }
    
    describe '#digit_patterns' do
      it 'transposes and formats digit patterns correctly' do
        patterns = instance.send(:digital_number_strings)
        
        expect(patterns.size).to eq(PolicyOcr::DIGITS_PER_LINE)
        patterns.each do |pattern|
          expect(pattern).to be_a(String)
          expect(pattern.length).to eq(12) # 4 rows * 3 chars per row
        end
      end
    end
    
    describe '#line' do
      it 'memoizes line from context' do
        expect(instance.send(:line)).to eq(context.line)
        expect(instance.send(:line)).to be(instance.send(:line)) # same object
      end
    end
  end
end