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

### Interactor Pattern

This application uses the [Interactor gem from CollectiveIdea](https://github.com/collectiveidea/interactor). This pattern uses a variation on the Command or Strategy pattern to express the basic business rules of the application. 
Some benefits of this approach include:

- **Separation of concerns**: Keeps business logic out of models, which tends to limit side-effects
- **Testability**: Small, focused classes make unit testing easier.
- **Reusability**: The same interactor can be used across different entry points (web, API, jobs).
- **Clarity**: Encourages clear, intention-revealing naming and structure for business operations.

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
- **DigitalInt::Invalid**: Handles unrecognizable digit patterns

#### Validation
- **ValidatePolicyNumberChecksum**: Implements weighted checksum validation using the formula: `(d1�1 + d2�2 + ... + d9�9) mod 11 = 0`

#### CLI Interface
- **PolicyOcr::Cli**: Thor-based command-line interface for parsing and generating policy numbers


### Parsing Workflow

This is the general sequence of parsing, starting with the ParsePolicyDocumentFile, which reads the file contents and passes the raw text to the ParsePolicyDocumentText interactor.

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
             │                               │                              │    policy_number          │           
             │                               │                              │◀──────────────────────────│           
             │                               │      policy_number           │                           │           
             │                               │◀─────────────────────────────│                           │           
             │    Array of Policy::Number    │                              │                           │           
             │◀──────────────────────────────│                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           
             │                               │                              │                           │           

### Design Patterns

- **Interactor Pattern**: Used for business logic with clear success/failure states
- **Factory Pattern**: DigitalInt creation from various input formats
- **Strategy Pattern**: Different handling for valid vs invalid policy numbers
