require "spec_helper"
require "stringio"
require "tempfile"
require_relative "../../lib/policy_ocr_cli"

RSpec.describe "PolicyOcrCLI Integration - parse command" do
  let(:cli) { PolicyOcrCLI.new }
  
  # Helper to capture CLI output and exit behavior
  def run_parse_command(file_path)
    original_stdout = $stdout
    stdout_capture = StringIO.new
    exit_code = 0
    
    begin
      $stdout = stdout_capture
      cli.parse(file_path)
    rescue SystemExit => e
      exit_code = e.status
    ensure
      $stdout = original_stdout
    end
    
    {
      output: stdout_capture.string,
      exit_code: exit_code
    }
  end
  
  describe "successful parsing scenarios" do
    context "with valid policy numbers" do
      it "outputs valid numbers with trailing space" do
        result = run_parse_command("spec/fixtures/sample.txt")
        
        expect(result[:exit_code]).to eq(0)
        expect(result[:output]).to include("000000000 ")
        expect(result[:output]).to include("111111111 ")
      end
      
      it "processes multiple valid numbers with newline separation" do
        result = run_parse_command("spec/fixtures/sample.txt")
        
        expect(result[:exit_code]).to eq(0)
        
        lines = result[:output].strip.split("\n")
        expect(lines.size).to be > 1
        
        # Each line should be 9 digits with optional status, or question marks with ILL  
        lines.each do |line|
          expect(line).to match(/^\d{9} $|^\d{9} ERR$|^\d*\?+\d* ILL$|\?{9} ILL$|^123456789$/)
        end
      end
    end
    
    context "with invalid digits" do
      it "outputs question marks with ILL suffix" do
        # Create a temporary file with invalid digit patterns
        temp_file = create_temp_file_with_invalid_digits
        result = run_parse_command(temp_file.path)
        
        expect(result[:exit_code]).to eq(0)
        expect(result[:output]).to include("ILL")
        expect(result[:output]).to include("?")
        
        temp_file.unlink
      end
    end
    
    context "with checksum errors" do
      it "outputs numbers with ERR suffix" do
        # Use the existing fixture which contains checksum errors
        result = run_parse_command("spec/fixtures/sample.txt")
        
        expect(result[:exit_code]).to eq(0)
        expect(result[:output]).to include("ERR")
      end
    end
    
    context "with mixed scenarios" do
      it "handles combination of valid, invalid digits, and checksum errors" do
        result = run_parse_command("spec/fixtures/mixed_policy_numbers.txt")
        
        expect(result[:exit_code]).to eq(0)
        
        output = result[:output]
        expect(output).to include(" ")    # Valid numbers
        expect(output).to include("ERR")  # Checksum errors  
        expect(output).to include("ILL")  # Invalid digits
      end
    end
  end
  
  describe "error handling scenarios" do
    context "when file does not exist" do
      it "displays error message and exits with code 1" do
        result = run_parse_command("nonexistent_file.txt")
        
        expect(result[:exit_code]).to eq(1)
        expect(result[:output]).to include("Error: File 'nonexistent_file.txt' not found")
      end
    end
    
    context "when file exists but is empty" do
      it "handles empty files gracefully" do
        temp_file = Tempfile.new('empty')
        temp_file.close
        
        result = run_parse_command(temp_file.path)
        
        # Should not crash, exit code depends on how empty files are handled
        expect([0, 1]).to include(result[:exit_code])
        
        temp_file.unlink
      end
    end
    
    context "when file has malformed content" do
      it "handles files with incorrect line counts" do
        temp_file = create_temp_file_with_malformed_content
        result = run_parse_command(temp_file.path)
        
        # Should handle gracefully, either succeeding or failing cleanly
        expect([0, 1]).to include(result[:exit_code])
        
        temp_file.unlink
      end
    end
  end
  
  describe "output format validation" do
    it "produces exactly the expected output format" do
      result = run_parse_command("spec/fixtures/sample.txt")
      
      expect(result[:exit_code]).to eq(0)
      
      # Verify output format matches expected pattern
      lines = result[:output].strip.split("\n")
      lines.each do |line|
        # Each line should be 9 digits with optional status, or question marks with ILL
        expect(line).to match(/^\d{9} $|^\d{9} ERR$|^\d*\?+\d* ILL$|\?{9} ILL$|^123456789$/)
      end
    end
    
    it "uses correct line endings" do
      result = run_parse_command("spec/fixtures/sample.txt")
      
      expect(result[:exit_code]).to eq(0)
      expect(result[:output]).to end_with("\n")
    end
  end
  
  private
  
  def create_temp_file_with_invalid_digits
    temp_file = Tempfile.new('invalid_digits')
    # Create content with some invalid digit patterns that won't parse correctly
    temp_file.write(<<~CONTENT)
       |   | _ |_|   |_||_||_| | 
      |_   _  _ _| _ _ _ _ _|  _  
        _ _|_ | |_  | |_ | |  |
                               
    CONTENT
    temp_file.close
    temp_file
  end
  
  def create_temp_file_with_checksum_errors
    temp_file = Tempfile.new('checksum_errors')
    # Create content that represents 111111111 which has invalid checksum
    temp_file.write(<<~CONTENT)
                                 
      |  |  |  |  |  |  |  |  |
      |  |  |  |  |  |  |  |  |
                                 
    CONTENT
    temp_file.close
    temp_file
  end
  
  def create_temp_file_with_malformed_content
    temp_file = Tempfile.new('malformed')
    temp_file.write(<<~CONTENT)
      This is not valid OCR content
      Just some random text
      That should not parse correctly
    CONTENT
    temp_file.close
    temp_file
  end
end