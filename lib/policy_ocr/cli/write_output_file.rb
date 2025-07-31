# frozen_string_literal: true

module PolicyOcr
  # rubocop:disable Style/ClassAndModuleChildren
  # Using compact style to avoid conflict with Cli class that inherits from Thor
  class Cli::WriteOutputFile
    # rubocop:enable Style/ClassAndModuleChildren
    include Interactor
    include Interactor::Validations

    before do
      validate_presence_of(:content, :input_file)
    end

    # Writes parsed policy document content to an output file.
    # Creates the output directory if it doesn't exist and generates
    # a filename based on the input file name with "_parsed" suffix.
    #
    # @param context [Interactor::Context] must contain:
    #   - content: the text content to write to the file
    #   - input_file: the original input file path (used to generate output filename)
    #   - output_dir: optional output directory (default: "parsed_files")
    # @return [Interactor::Context] with output_file path set
    def call
      output_dir = context.output_dir || "parsed_files"
      FileUtils.mkdir_p(output_dir)

      base_name = File.basename(context.input_file, ".*")
      output_filename = File.join(output_dir, "#{base_name}_parsed.txt")

      File.write(output_filename, context.content)
      context.output_file = output_filename
    end
  end
end
