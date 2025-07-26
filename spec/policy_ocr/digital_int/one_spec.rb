require 'spec_helper'

RSpec.describe PolicyOcr::DigitalInt::One do
  describe '.pattern' do
    it 'returns correct pattern' do
      expected = "   " + "  |" + "  |" + "   "
      expect(described_class.pattern).to eq(expected)
    end
  end
  
  describe '#to_i' do
    it 'returns 1' do
      expect(described_class.new.to_i).to eq(1)
    end
  end
end