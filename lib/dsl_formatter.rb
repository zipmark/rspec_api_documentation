require 'rspec/core/formatters/base_text_formatter'

class DSLFormatter < RSpec::Core::Formatters::BaseTextFormatter
  def example_passed(example)
    super

    require "pp"
    pp example.http_method
  end
end
