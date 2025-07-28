FactoryBot.define do
  factory :interactor_context, class: Interactor::Context do
    initialize_with { new(attributes) }
  end

  factory :policy_ocr_context, parent: :interactor_context do
    file_path { "./spec/fixtures/sample.txt" }
  end

  factory :read_lines_context, parent: :interactor_context do
    raw_text { fixture("sample") }
  end

  factory :parse_line_context, parent: :interactor_context do
    line do
      [
        " _  _  _  _  _  _  _  _  _ ",
        "| || || || || || || || || |",
        "|_||_||_||_||_||_||_||_||_|",
        "                           "
      ]
    end
  end
end