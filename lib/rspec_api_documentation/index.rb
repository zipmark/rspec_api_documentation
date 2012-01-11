module RspecApiDocumentation
  class Index
    def examples
      @examples ||= []
    end

    def sections
      resources = examples.group_by(&:resource_name).inject([]) do |arr, (resource_name, examples)|
        arr << { :resource_name => resource_name, :examples => examples.sort_by(&:description) }
      end
      resources.sort_by { |resource| resource[:resource_name] }
    end
  end
end
