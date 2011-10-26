module RspecApiDocumentation
  class Index < Mustache
    def add_example(example)
      examples << Example.new(example)
    end

    def sections
      examples.group_by(&:resource_name).inject([]) do |arr, (resource_name, examples)|
        arr << { :resource_name => resource_name, :examples => examples }
      end
    end

    def examples
      @examples ||= []
    end
  end
end
