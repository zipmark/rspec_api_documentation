require 'rspec/core/formatters/base_formatter'

module RspecApiDocumentation
  class ApiFormatter < RSpec::Core::Formatters::BaseFormatter
    def initialize(output)
      super

      output.puts "Generating API Docs"
    end

    def start(example_count)
      super

      RspecApiDocumentation.configurations.each(&:clear_docs)
    end

    def example_group_started(example_group)
      super

      output.puts "  #{example_group.description}"
    end

    def example_passed(example)
      super

      output.puts "    * #{example.description}"

      RspecApiDocumentation.configurations.each do |documentation|
        documentation.document_example(example)
      end
    end

    def example_failed(example)
      super

      output.puts "    ! #{example.description} (FAILED)"
    end

    def stop
      super

      RspecApiDocumentation.configurations.each do |documentation|
        documentation.write_private_index
        documentation.write_public_index
        documentation.write_examples
        documentation.symlink_public_examples
      end
    end
  end
end
