# Error Correction Algorithm

## Overview
The error correction system attempts to fix OCR errors in policy numbers by trying single-character modifications (adding or removing one pipe `|` or underscore `_`). This is based on the observation that OCR scanners often miss a single stroke when reading seven-segment displays.

## Key Concepts

### Weight Distance
Each digit in our seven-segment display has a "weight" - the total number of segments (pipes and underscores) used to display it:
- The weight represents how many strokes are "on" in the seven-segment display
- Two digits are "adjacent" if their weights differ by exactly 1
- This models the OCR error of missing or adding a single stroke

### Correction Strategy
The algorithm attempts corrections for policy numbers that are either:
- `ERR`: Valid digits but invalid checksum
- `ILL`: Contains one or more invalid/unrecognizable digits

## Algorithm Flow

### 1. Initial Validation
- Receive a policy number that failed validation (ERR or ILL)
- Identify all invalid digit positions (for ILL numbers)
- For ERR numbers, all positions are candidates for correction

### 2. Generate Candidates

#### For Numbers with Invalid Digits (ILL):
1. For each invalid digit position:
   - Find all valid digits that could be adjacent (weight ±1 from possible originals)
   - Since we don't know the original weight, we must consider all valid digits as potential starting points
2. Generate candidate policy numbers by:
   - Replacing invalid digits with valid adjacent candidates
   - For multiple invalid digits, create combinations of all possible replacements

#### For Numbers with Valid Digits but Wrong Checksum (ERR):
1. For each digit position (0-8):
   - Find all digits with weight = current_weight ± 1
   - Generate a candidate by replacing just that one digit
   - This models a single OCR error at that position

### 3. Validate Candidates
For each candidate policy number generated:
1. Ensure all digits are valid
2. Run checksum validation
3. Keep track of all candidates that pass both validations

### 4. Determine Final Status

Based on the validation results:
- **No valid candidates found**: 
  - Return original status (ILL or ERR)
- **Exactly one valid candidate found**: 
  - Return the corrected policy number with no status message
- **Multiple valid candidates found**: 
  - Return status `AMB` (ambiguous)
  - Store all valid alternatives for potential manual review

## Implementation Details

### Candidate Generation Loop

```
For each position i in policy_number:
  current_digit = policy_number[i]
  
  If current_digit is invalid:
    # For invalid digits, try all valid digits as candidates
    For each valid_digit in all_valid_digits:
      candidate = copy(policy_number)
      candidate[i] = valid_digit
      If all digits now valid:
        test_candidates.add(candidate)
  
  Else if current_digit is valid:
    # For valid digits, try adjacent weights only
    current_weight = current_digit.weight
    For each adjacent_digit with weight in [current_weight-1, current_weight+1]:
      candidate = copy(policy_number)
      candidate[i] = adjacent_digit
      test_candidates.add(candidate)
```

### Handling Multiple Invalid Digits

When a policy number has multiple invalid digits, the algorithm must:
1. First establish valid digits at all invalid positions
2. Then try single-stroke variations from that base
3. This can lead to a combinatorial explosion, so we may need to limit the search

Example:
- Original: `?2345678?` (two invalid digits)
- Must try all combinations of valid digits for positions 0 and 8
- For each valid combination, then try adjacent variations

### Edge Cases

1. **All digits invalid**: Skip correction (remains ILL)
2. **No adjacent candidates exist**: Some digits may have no valid adjacent digits
3. **Checksum position (digit 8)**: Changes here have special weight in validation
4. **Performance**: Limit search depth for numbers with many invalid digits

## Status Codes

- **(blank)**: Valid number or successfully corrected
- **ERR**: Invalid checksum, no unique correction found
- **ILL**: Invalid digits, no unique correction found  
- **AMB**: Multiple valid corrections exist (ambiguous)

## Future Enhancements

1. **Confidence Scoring**: Weight candidates by likelihood of specific OCR errors
2. **Context Awareness**: Use patterns from successfully corrected numbers
3. **Manual Override**: Allow human review of AMB cases
4. **Error Patterns**: Learn common OCR mistakes for better predictions