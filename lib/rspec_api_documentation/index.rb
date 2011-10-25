module RspecApiDocumentation
  class Index < Mustache
    def add_example(example)
      examples << Example.new(example)
    end

    def example_groups
      examples.map(&:example_group).uniq
    end

    def examples
      @examples ||= []
    end
  end
end
