# frozen_string_literal: true
module PolicyOcr
  module DigitalInt

    # This is far too clever and magical and I would probably not approve in a production PR, BUT some advantages might be:
    #   - The YAML file is more readable than lots of class definitions
    #   - It would allow easy addition of new digital chars, and correction or modifications of existing ones
    #   - It lays the groundwork to support an entirely different set of digital chars if needed
    #   - YES, This is still too much ruby magic, and would definitely not be the right initial approach
    #   - YES, it was kind of fun to do
    #
    # Alternative approaches:
    #   - Define each class manually, either in separate classes under lib/policy_ocr/digital_int/, or with 
    #     all class definitions in this file.
    #   - A simple array of hashes, with digit names, int values and patterns, and then a single class that
    #     takes the digit name and returns the pattern and value.
    #
    # This will generate classes with the general pattern:
    #
    #  class Zero < PolicyOcr::DigitalInt::Base
    #    def intialize
    #      @int_value = 0
    #    end
    #
    #    def self.pattern
    #      @pattern = "  _ | | |_|     "
    #    end
    #  end
    #  
    def self.load_all
      digital_int_config = YAML.load(File.read(PolicyOcr::DIGITAL_INTS_CONFIG_PATH))

      digital_int_config["digits"].each do |digit_config|
        class_eval <<-RUBY
          class #{digit_config["name"].split("_").map(&:capitalize).join} < Base
            def self.pattern 
              # we"d want to find a cleaner yaml format for the pattern, but this makes it readable
              "#{digit_config["pattern"].delete("\n").delete("\"")}" 
            end

            def initialize
              @int_value = #{digit_config["value"]}
            end
          end
        RUBY
      end
    end

    def self.all_numbers
      [Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine]
    end

    def self.from_pattern(pattern)
      klass = all_numbers.find { |k| k.pattern == pattern }

      if klass.nil?
        return PolicyOcr::DigitalInt::Invalid.new(pattern:)
      end

      klass.new
    end
  end
end
      
