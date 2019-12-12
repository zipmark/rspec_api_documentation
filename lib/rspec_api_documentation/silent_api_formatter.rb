require 'rspec/core/formatters/base_formatter'

module RspecApiDocumentation
  class SilentApiFormatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register self, :example_passed, :stop

    def start(notification)
      super

      RspecApiDocumentation.documentations.each(&:clear_docs)
    end

    def example_passed(notification)
      RspecApiDocumentation.documentations.each do |documentation|
        documentation.document_example(example_notification.example)
      end
    end

    def stop(notification)
      RspecApiDocumentation.documentations.each(&:write)
    end
  end
end
