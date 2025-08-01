# PolicyOCR

## Description

PolicyOCR is a Ruby application that parses policy numbers from ASCII digital format text files. The system processes OCR-scanned policy documents where each policy number is represented using ASCII art-style digit patterns, validates checksums, and outputs formatted results with appropriate error messages for invalid digits and checksum failures.

## Getting Started

### Prerequisites

- **Ruby 3.0 or higher** (tested with Ruby 3.4.4)
- **Bundler** (gem install bundler if not installed)
- **Git** (for cloning the repository)

### Installation

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone <repository-url>
   cd policy-number-challenge
   ```

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Verify installation**:
   ```bash
   ./policy_ocr --help
   # OR using bundle exec:
   bundle exec ./policy_ocr --help
   ```

   You should see the Thor help output showing available commands.

4. **Make executable** (optional):
   ```bash
   chmod +x policy_ocr
   ```

### Quick Start

Test the application using sample files:

```bash
# Parse a sample file
./policy_ocr parse spec/fixtures/sample.txt

# Generate test data  
./policy_ocr generate_policy_numbers > test_data.txt
./policy_ocr parse test_data.txt

# View results
ls parsed_files/
ls log/
```

**Note**: Use `bundle exec ./policy_ocr` if you encounter permission issues.

## Usage

### Commands

**Parse policy numbers:**
```bash
./policy_ocr parse <input_file>
```

**Generate test data:**
```bash
./policy_ocr generate_policy_numbers
```

### Input File Format

PolicyOCR expects ASCII art representations of 9-digit policy numbers. Each policy number occupies exactly 4 lines:

```
 _  _  _  _  _  _  _  _  _ 
| || || || || || || || || |
|_||_||_||_||_||_||_||_||_|
                           
```

**Format Rules:**
- Each digit is 3 characters wide
- Policy numbers are separated by blank lines
- Invalid digits are represented with `?` characters
- Files can contain multiple policy numbers

### Example Output

**Parsing a file with mixed results** (`spec/fixtures/mixed_policy_numbers.txt`):

```
============================================================
✅ SUCCESSFULLY PARSED mixed_policy_numbers.txt
============================================================

📄 Input File: spec/fixtures/mixed_policy_numbers.txt
📝 Output File: parsed_files/mixed_policy_numbers_parsed.txt
📋 Log File: log/mixed_policy_numbers_parsed.log

📈 PARSING STATISTICS:
  Total Lines Parsed: 30
  ✅ Valid Numbers: 20
  ❌ Checksum Errors (ERR): 4
  ❓ Invalid Digits (ILL): 6

✨ Parsing completed successfully!
============================================================
```

**Parsing a file with parsing errors** (`spec/fixtures/malformed_content.txt`):

```
============================================================
⚠️  PARSED malformed_content.txt WITH ERRORS
============================================================

📄 Input File: spec/fixtures/malformed_content.txt
📝 Output File: parsed_files/malformed_content_parsed.txt
📋 Log File: log/malformed_content_parsed.log

📈 PARSING STATISTICS:
  Total Lines Parsed: 4
  ✅ Valid Numbers: 1
  ❌ Checksum Errors (ERR): 2
  ❓ Invalid Digits (ILL): 1

⚠️  PARSER ERRORS ENCOUNTERED:
  1. Malformed number line at 3: element size differs (7 should be 10)

✨ Parsing completed successfully!
============================================================
```

### Sample Files

Test with included sample files:

- `spec/fixtures/sample.txt` - Basic valid policy numbers
- `spec/fixtures/mixed_policy_numbers.txt` - Mix of valid, ERR, and ILL numbers  
- `spec/fixtures/checksum_errors.txt` - Checksum validation failures
- `spec/fixtures/invalid_digits.txt` - Unrecognizable digit patterns
- `spec/fixtures/malformed_content.txt` - Malformed input for error testing

### Running Tests

```bash
bundle exec rspec
```

### Troubleshooting

#### Command Not Found: `./policy_ocr`
- **Solution**: Make sure you're in the project directory and the file is executable:
  ```bash
  chmod +x policy_ocr
  ```
- **Alternative**: Use `bundle exec` instead:
  ```bash
  bundle exec ./policy_ocr --help
  ```

#### Bundle Installation Issues
- **Ruby Version**: Ensure you're using Ruby 3.0 or higher:
  ```bash
  ruby --version
  ```
- **Bundler Not Found**: Install bundler:
  ```bash
  gem install bundler
  ```
- **Permission Issues**: Try using `--user-install` flag:
  ```bash
  bundle install --user-install
  ```

#### File Not Found Errors
- **Check File Path**: Ensure the input file exists and path is correct
- **Relative vs Absolute Paths**: Try using absolute paths if relative paths don't work
- **File Permissions**: Ensure the input file is readable:
  ```bash
  ls -la your_input_file.txt
  ```

#### Empty or Incorrect Output
- **Check Input Format**: Ensure your input file follows the exact ASCII art format
- **View Sample Files**: Compare your input with files in `spec/fixtures/`:
  ```bash
  cat spec/fixtures/sample.txt
  ```
- **Check Logs**: Review the detailed log files in `log/` directory for parsing errors
- **Test with Known Good File**: Try parsing a sample file first:
  ```bash
  ./policy_ocr parse spec/fixtures/sample.txt
  ```


## Architecture

### Interactor Pattern

This application uses the [Interactor gem from CollectiveIdea](https://github.com/collectiveidea/interactor). This pattern uses a variation on the Command or Strategy pattern to express the basic business rules of the application. 
Some benefits of this approach include:

- **Separation of concerns**: Keeps business logic out of models, which tends to limit side-effects
- **Testability**: Small, focused classes make unit testing easier.
- **Reusability**: The same interactor can be used across different entry points (web, API, jobs).
- **Clarity**: Encourages clear, intention-revealing naming and structure for business operations.

**Key Features:**
- **Thor-based**: Uses the Thor gem for robust command-line argument parsing and help system
- **Error Handling**: Graceful handling of file not found, parsing errors, and system exceptions
- **Logging**: Thread-local logging with detailed debugging information stored in `log/` directory
- **Output Management**: Automatic directory creation and file naming based on input files
- **Separation of Concerns**: Each CLI operation is handled by a dedicated interactor

### Core Components

#### Policy Classes (`lib/policy_ocr/policy/`)
- **Document**: Represents a collection of policy numbers from a document
- **Number**: Represents a single policy number with validation and formatting
- **Number::Invalid**: Subclass for handling unparseable policy numbers

#### Parser Classes (`lib/policy_ocr/parser/`)
- **ParsePolicyDocumentFile**: Reads and processes policy document files
- **ParsePolicyDocumentText**: Parses raw text into policy numbers
- **ParsePolicyNumberLine**: Converts ASCII digit patterns into policy numbers

#### Digital Integer System (`lib/policy_ocr/digital_int/`)
- **DigitalInt::Base**: Base class for digital representations
- **DigitalInt**: Factory for creating digit instances from patterns
- **DigitalInt::Zero through Nine**: Individual classes for each digit (0-9) with readable ASCII art patterns
- **DigitalInt::Invalid**: Handles unrecognizable digit patterns

Each digit class contains its ASCII art pattern in a readable 3-line format as requested by the challenge:
```ruby
def self.pattern
  " _ " +
  "|_|" +
  "|_|"
end
```

#### Validation
- **ValidatePolicyNumberChecksum**: Implements weighted checksum validation using the formula: `(d1�1 + d2�2 + ... + d9�9) mod 11 = 0`

#### CLI Interface (`lib/policy_ocr/cli/`)
- **PolicyOcr::Cli**: Thor-based command-line interface for parsing and generating policy numbers
- **PrintReport**: Interactor for displaying parsing results and statistics
- **WriteOutputFile**: Interactor for writing parsed results to output files with proper directory structure
- **GenerateSamplePolicyNumbers**: Interactor for generating test policy numbers with configurable distributions


### Class Organization

The final output structure of a parsed document has the following class organization:

```
┌───────────────────────────────────────────────────────────────────────────────────────────┐
│                                      Parsed Document                                      │
│                                                                                           │
│                                                                                           │
│    ┌──────────────────┐         ┌──────────────────┐           ┌──────────────────┐       │
│    │ Policy::Document │         │  Policy::Number  │           │    DigitalInt    │       │
│    │                  │         │                  │           │                  │       │
│    │policy_numbers    │────────▶│digital_ints      │─────────▶ │int_value         │       │
│    │                  │         │                  │           │pattern           │       │
│    │                  │         │                  │           │                  │       │
│    └──────────────────┘         └──────────────────┘           └──────────────────┘       │
│                                                                                           │
│                                                                                           │
│                                                                                           │
│                                                                                           │
└───────────────────────────────────────────────────────────────────────────────────────────┘
```

### Parsing Workflow

This is the general sequence of parsing, starting with the ParsePolicyDocumentFile, which reads the file contents and passes the raw text to the ParsePolicyDocumentText interactor.

```
┌─────────────────────────┐     ┌─────────────────────────┐     ┌───────────────────────┐    ┌─────────────────────┐
│                         │     │                         │     │                       │    │                     │
│                         │     │                         │     │                       │    │                     │
│ ParsePolicyDocumentFile │     │ ParsePolicyDocumentText │     │ ParsePolicyNumberLine │    │   Policy::Number    │
│                         │     │                         │     │                       │    │                     │
│                         │     │                         │     │                       │    │                     │
└────────────┬────────────┘     └────────────┬────────────┘     └───────────┬───────────┘    └──────────┬──────────┘
             │                               │                              │                           │           
             │                               │                              │                           │           
             │           raw_text            │                              │                           │           
             ├──────────────────────────────▶│                              │                           │           
             │                               │        number_line           │                           │           
             │                               │─────────────────────────────▶│                           │           
             │                               │                              │        create             │           
             │                               │                              ├──────────────────────────▶│           
             │                               │                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           
             │                               │                              │      Policy::Number       │           
             │                               │                              │◀──────────────────────────│           
             │                               │       Policy::Number         │                           │           
             │                               │◀─────────────────────────────│                           │           
             │        Policy::Document       │                              │                           │           
             │◀──────────────────────────────│                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           

```

### CLI Interface Workflow

The command-line interface orchestrates the parsing workflow through specialized interactors:

```
┌─────────────────┐    ┌─────────────────────────┐     ┌─────────────────┐       ┌─────────────────┐
│                 │    │                         │     │                 │       │                 │
│       CLI       │    │ ParsePolicyDocumentFile │     │ WriteOutputFile │       │   PrintReport   │
│                 │    │                         │     │                 │       │                 │
└────────┬────────┘    └────────────┬────────────┘     └────────┬────────┘       └────────┬────────┘
         │                          │                           │                         │         
         │                          │                           │                         │         
         │           call           │                           │                         │         
         │─────────────────────────▶│                           │                         │         
         │                          │                           │                         │         
         │           result         │                           │                         │         
         │◀─────────────────────────┤                           │                         │         
         │                          │                           │                         │         
         │                          │                           │                         │         
         │                          │    call                   │                         │         
         │──────────────────────────┼──────────────────────────▶│                         │         
         │                          │                           │                         │         
         │                          │   result                  │                         │         
         │◀─────────────────────────┼───────────────────────────│                         │         
         │                          │                           │                         │         
         │                          │                           │                         │         
         │                          │            call           │                         │         
         │──────────────────────────┼───────────────────────────┼────────────────────────▶│         
         │                          │                           │                         │         
         │                          │                           │                         │         
         │                          │                           │                         │         
```
