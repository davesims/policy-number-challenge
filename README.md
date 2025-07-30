# PolicyOCR

## Description

PolicyOCR is a Ruby application that parses policy numbers from ASCII digital format text files. The system processes OCR-scanned policy documents where each policy number is represented using ASCII art-style digit patterns, validates checksums, and outputs formatted results with appropriate error messages for invalid digits and checksum failures.

## Getting Started

### Prerequisites

- Ruby 3.x
- Bundler

### Installation

```bash
bundle install
```

### Usage

Parse policy numbers from a text file:

```bash
policy_ocr parse path/to/policy_file.txt
```

Generate test policy numbers:

```bash
policy_ocr generate_policy_numbers
```

### Running Tests

```bash
bundle exec rspec
```

## Architecture

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
- **Base**: Base class for digital representations
- **DigitalInts**: Factory for creating digit instances from patterns
- **Invalid**: Handles unrecognizable digit patterns

#### Validation
- **ValidatePolicyNumberChecksum**: Implements weighted checksum validation using the formula: `(d1×1 + d2×2 + ... + d9×9) mod 11 = 0`

#### CLI Interface
- **PolicyOcrCLI**: Thor-based command-line interface for parsing and generating policy numbers

### Design Patterns

- **Interactor Pattern**: Used for business logic with clear success/failure states
- **Factory Pattern**: DigitalInt creation from various input formats
- **Strategy Pattern**: Different handling for valid vs invalid policy numbers