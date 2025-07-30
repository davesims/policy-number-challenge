# frozen_string_literal: true
require "yaml"

module PolicyOcr
  module DigitalInt

    # This is too clever and magical and I would probably not use this approach in a production PR. 
    # That said, it's a good exercise in metaprogramming, and some advantages of this might be:
    #   - The YAML file is more readable than lots of class definitions
    #   - It would allow easy addition of new digital chars, and correction or modifications of existing ones
    #   - It lays the groundwork to support an entirely different set of digital chars if needed
    #   - Yes, this is still too much ruby magic, and would definitely not be the right initial approach
    #   - Yes, it was kind of fun to do
    #
    # Alternative approaches:
    #   - Define each class explicitly, either in separate classes under lib/policy_ocr/digital_int/, or with 
    #     all class definitions in this file.
    #   - Instead of POROs for each int, use a simple array of hashes, with digit names, int values and patterns,
    #     and then a single class that takes the digit name and returns the pattern and value.
    #
    # The load_all method will iterate over the configurations in the yaml file and the eval block will generate
    # classes with the general pattern:
    #
    #  class PolicyOcr::DigitalInt::Zero < PolicyOcr::DigitalInt::Base
    #    def intialize
    #      @int_value = 0
    #    end
    #
    #    def self.pattern
    #      @pattern = " _ " + 
    #                 "| |" + 
    #                 "|_|"
    #    end
    #  end
    #  
    def self.load_all
      digital_int_definitions["digits"].each do |digit_definition|
        class_eval <<-DIGITAL_INT
          class #{digit_definition["name"].split("_").map(&:capitalize).join} < Base
            def self.pattern 
              "#{digit_definition["pattern"].delete("\n").delete("\"")}" 
            end

            def initialize
              @int_value = #{digit_definition["value"]}
            end
          end
        DIGITAL_INT
      end
    end

    def self.digital_int_definitions
      @digital_int_definitions ||= YAML.load(File.read(PolicyOcr::DIGITAL_INTS_DEFINITION_PATH))
    end

    def self.all_numbers
      [Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine]
    end

    def self.from_pattern(pattern)
      klass = all_numbers.find { |k| k.pattern == pattern }

      if klass.nil?
        PolicyOcr.logger_for(self).warn "Invalid pattern: #{pattern}. Returning Invalid instance."
        return PolicyOcr::DigitalInt::Invalid.new(pattern:)
      end

      klass.new
    end

    def self.from_int(int)
      unless int.between?(0, 9)
        PolicyOcr.logger_for(self).error "Invalid int value given: #{int}."
        return PolicyOcr::DigitalInt::Invalid.new(pattern: "?")
      end

      klass = all_numbers.find { |k| k.new.to_i == int }
      klass.new
    end

    # Load all digital int classes whenever this module is evaluated.
    load_all
  end
end
      
