require_relative '../lib/read_digit_line.rb'
require_relative '../lib/digital_number.rb'

describe ReadDigitLine do
  let(:line) {
    %Q{
    _  _     _  _  _  _  _ 
  | _| _||_||_ |_   ||_||_|
  ||_  _|  | _||_|  ||_| _|
                           
}
  }

  subject { ReadDigitLine.call(line: line) }

  it "succeeds" do
    expect(subject).to be_success
    expect(subject.digits[0]).to eq(PolicyOcr::DigitalInt::One)
  end
end
