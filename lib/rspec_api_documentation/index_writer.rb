module RspecApiDocumentation
  module IndexWriter
    def sections(examples, configuration)
      resources = examples.group_by(&:resource_name).inject([]) do |arr, (resource_name, examples)|
        ordered_examples = configuration.keep_source_order ? examples : examples.sort_by(&:description)
        arr << { :resource_name => resource_name, :examples => ordered_examples }
      end
      configuration.keep_source_order ? resources : resources.sort_by { |resource| resource[:resource_name] }
    end
    module_function :sections
  end
end
