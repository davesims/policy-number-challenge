# frozen_string_literal: true

FactoryBot.define do
  factory :interactor_context, class: 'Interactor::Context' do
    initialize_with { new(attributes) }
  end

  factory :policy_ocr_context, parent: :interactor_context do
    file_path { "./spec/fixtures/sample.txt" }
  end

  factory :read_lines_context, parent: :interactor_context do
    raw_text { fixture("sample") }
  end

  factory :policy_number_line_context, parent: :interactor_context do
    number_line do
      [
        " _  _  _  _  _  _  _  _  _ ",
        "| || || || || || || || || |",
        "|_||_||_||_||_||_||_||_||_|"
      ]
    end
  end

  factory :failed_interactor_context, parent: :interactor_context do
    after(:build) do |context|
      context.instance_variable_set(:@failure, true)
      context.error = "Interactor failed"
    end
  end
end
