require 'spec_helper'

RSpec.describe PolicyOcr::DigitalInt::Zero do
  describe '.pattern' do
    it 'returns correct pattern' do
      expected = " _ " + "| |" + "|_|" + "   "
      expect(described_class.pattern).to eq(expected)
    end
  end
  
  describe '#to_i' do
    it 'returns 0' do
      expect(described_class.new.to_i).to eq(0)
    end
  end
end