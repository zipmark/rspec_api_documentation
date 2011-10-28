module RspecApiDocumentation
  class Index < Mustache
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
      @template_path = configuration.template_path
      @template_extension = configuration.template_extension
    end

    def sections
      examples.group_by(&:resource_name).inject([]) do |arr, (resource_name, examples)|
        arr << { :resource_name => resource_name, :examples => examples }
      end
    end

    def examples
      @examples ||= []
    end

    def json
      sections.inject({:resources => []}) do |h, section|
        h[:resources].push(
          :name => section[:resource_name],
          :examples => examples.map { |example|
            {
              :description => example.description,
              :link => "#{example.dirname}/#{example.filename}"
            }
          }
        )
        h
      end.to_json
    end
  end
end
