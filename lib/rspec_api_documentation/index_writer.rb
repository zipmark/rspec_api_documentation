module RspecApiDocumentation
  module IndexWriter
    def sections(examples)
      resources = examples.group_by(&:resource_name).inject([]) do |arr, (resource_name, examples)|
        arr << { :resource_name => resource_name, :examples => examples.sort_by(&:description) }
      end
      resources.sort_by { |resource| resource[:resource_name] }
    end
    module_function :sections
  end
end
