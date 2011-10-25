module RspecApiDocumentation
  class Index < Mustache
    def add_example(example)
      examples << example
    end

    def example_groups
      examples.map(&:example_group).uniq.map do |example_group|
        ExampleGroup.new(example_group)
      end
    end

    private

    def examples
      @examples ||= []
    end
  end
end
