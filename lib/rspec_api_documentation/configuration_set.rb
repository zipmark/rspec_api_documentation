module RspecApiDocumentation
  class ConfigurationSet
    def method_missing(selector, *args)
      configuration = Configuration.new
      configurations[selector] = configuration
      yield configuration if block_given?
    end

    def configurations
      @configurations ||= {}
    end
  end
end
