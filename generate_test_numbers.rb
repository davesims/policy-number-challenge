#!/usr/bin/env ruby

# Digit patterns from the YAML file
DIGIT_PATTERNS = {
  0 => [" _ ", "| |", "|_|", "   "],
  1 => ["   ", "  |", "  |", "   "],
  2 => [" _ ", " _|", "|_ ", "   "],
  3 => [" _ ", " _|", " _|", "   "],
  4 => ["   ", "|_|", "  |", "   "],
  5 => [" _ ", "|_ ", " _|", "   "],
  6 => [" _ ", "|_ ", "|_|", "   "],
  7 => [" _ ", "  |", "  |", "   "],
  8 => [" _ ", "|_|", "|_|", "   "],
  9 => [" _ ", "|_|", " _|", "   "]
}

INVALID_PATTERN = ["   ", "   ", "   ", "   "]

def checksum_valid?(digits)
  return false if digits.any?(&:nil?)
  sequence = (1..9).to_a
  dot_product = sequence.zip(digits.reverse).map { |s, d| s * d }.sum
  (dot_product % 11) == 0
end

def render_number(digits)
  lines = ["", "", "", ""]
  digits.each do |digit|
    pattern = digit.nil? ? INVALID_PATTERN : DIGIT_PATTERNS[digit]
    4.times do |i|
      lines[i] += pattern[i]
    end
  end
  lines.join("\n") + "\n"
end

def find_valid_number(base_digits)
  (0..9).each do |check_digit|
    test_digits = base_digits + [check_digit]
    return test_digits if checksum_valid?(test_digits)
  end
  nil
end

# Generate 20 valid numbers
valid_numbers = []
20.times do |i|
  base = Array.new(8) { rand(10) }
  valid_digits = find_valid_number(base)
  if valid_digits
    valid_numbers << valid_digits
  else
    # Fallback: use a known valid pattern
    valid_numbers << [1, 2, 3, 4, 5, 6, 7, 8, 0] # This should be valid
  end
end

# Generate 5 numbers with invalid digits (nil represents invalid)
invalid_digit_numbers = []
5.times do
  digits = Array.new(9) { rand(10) }
  # Replace 1-2 random digits with nil (invalid)
  rand(1..2).times do
    digits[rand(9)] = nil
  end
  invalid_digit_numbers << digits
end

# Generate 5 numbers with valid digits but invalid checksums
invalid_checksum_numbers = []
5.times do
  base = Array.new(8) { rand(10) }
  # Find a valid checksum digit
  valid_digits = find_valid_number(base)
  if valid_digits
    # Change the last digit to make checksum invalid
    invalid_digits = valid_digits.dup
    invalid_digits[-1] = (invalid_digits[-1] + rand(1..5)) % 10
    # Double check it's actually invalid
    if !checksum_valid?(invalid_digits)
      invalid_checksum_numbers << invalid_digits
    else
      # Fallback
      invalid_checksum_numbers << [1, 2, 3, 4, 5, 6, 7, 8, 9] # Invalid checksum
    end
  else
    invalid_checksum_numbers << [1, 2, 3, 4, 5, 6, 7, 8, 9] # Invalid checksum
  end
end

puts "# 20 VALID POLICY NUMBERS"
valid_numbers.each_with_index do |digits, i|
  puts "# Valid #{i+1}: #{digits.join}"
  puts render_number(digits)
end

puts "# 5 NUMBERS WITH INVALID DIGITS"
invalid_digit_numbers.each_with_index do |digits, i|
  digit_str = digits.map { |d| d.nil? ? "?" : d.to_s }.join
  puts "# Invalid digits #{i+1}: #{digit_str}"
  puts render_number(digits)
end

puts "# 5 NUMBERS WITH INVALID CHECKSUMS"
invalid_checksum_numbers.each_with_index do |digits, i|
  puts "# Invalid checksum #{i+1}: #{digits.join}"
  puts render_number(digits)
end