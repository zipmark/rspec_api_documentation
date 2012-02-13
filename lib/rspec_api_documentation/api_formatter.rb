require 'rspec/core/formatters/base_text_formatter'

module RspecApiDocumentation
  class ApiFormatter < RSpec::Core::Formatters::BaseTextFormatter
    def initialize(output)
      super

      output.puts "Generating API Docs"
    end

    def start(example_count)
      super

      RspecApiDocumentation.documentations.each(&:clear_docs)
    end

    def example_group_started(example_group)
      super

      output.puts "  #{example_group.description}"
    end

    def example_passed(example)
      super

      output.puts "    * #{example.description}"

      RspecApiDocumentation.documentations.each do |documentation|
        documentation.document_example(example)
      end
    end

    def example_failed(example)
      super

      output.puts "    ! #{example.description} (FAILED)"
    end

    def stop
      super

      RspecApiDocumentation.documentations.each(&:write)
    end
  end
end
