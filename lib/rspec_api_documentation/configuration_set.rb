module RspecApiDocumentation
  class ConfigurationSet
    include Enumerable

    def method_missing(selector, *args)
      configuration = Configuration.new
      yield configuration if block_given?
      configurations[selector] = ApiDocumentation.new(configuration)
    end

    def configurations
      @configurations ||= {}
    end

    def each(&block)
      configurations.each_value &block
    end
  end
end
