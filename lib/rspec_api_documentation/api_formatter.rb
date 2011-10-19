require 'rspec/core/formatters/base_formatter'

module RspecApiDocumentation
  class ApiFormatter < RSpec::Core::Formatters::BaseFormatter
    def initialize(output)
      super(output)

      puts "Generating API docs"
    end

    def clear_docs
      unless @cleared
        ApiDocumentation.clear_docs
      end

      @cleared = true
    end

    def example_group_started(example_group)
      clear_docs

      puts "\t * #{ExampleGroup.new(example_group).resource_name}"
    end

    def example_group_finished(example_group)
      ApiDocumentation.index(example_group)
      ExampleGroup.new(example_group).symlink_public_examples
    end

    def example_passed(example)
      return unless Example.new(example).should_document?

      puts "\t\t * #{example.description}"

      ApiDocumentation.document_example(example, template)
    end

    def example_failed(example)
      application_callers = example.metadata[:caller].select { |file_line| file_line =~ /^#{Rails.root}/ }
      example = Example.new(example)
      puts "\t*** EXAMPLE FAILED ***. #{example.resource_name}. Tests should pass before we generate docs."
      puts "\t\tDetails: #{example.metadata[:execution_result][:exception]}"
      print "\t\tApplication Backtrace:\n\t\t"
      puts application_callers.join("\n\t\t")
    end

    private
    def template
      File.read(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'example_template.html'))
    end
  end
end
