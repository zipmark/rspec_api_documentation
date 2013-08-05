module RspecApiDocumentation
  class Configuration
    include Enumerable

    attr_reader :parent

    def initialize(parent = nil)
      @parent = parent
      @settings = parent.settings.clone if parent
    end

    def groups
      @groups ||= []
    end

    def define_group(name, &block)
      subconfig = self.class.new(self)
      subconfig.filter = name
      subconfig.docs_dir = self.docs_dir.join(name.to_s)
      yield subconfig
      groups << subconfig
    end

    def self.add_setting(name, opts = {})
      define_method("#{name}=") { |value| settings[name] = value }
      define_method("#{name}") do
        if settings.has_key?(name)
          settings[name]
        elsif opts[:default].respond_to?(:call)
          opts[:default].call(self)
        else
          opts[:default]
        end
      end
    end

    add_setting :docs_dir, :default => lambda { |config|
      if defined?(Rails)
        Rails.root.join("doc", "api")
      else
        Pathname.new("doc/api")
      end
    }

    add_setting :format, :default => :html
    add_setting :template_path, :default => File.expand_path("../../../templates", __FILE__)
    add_setting :filter, :default => :all
    add_setting :exclusion_filter, :default => nil
    add_setting :app, :default => lambda { |config|
      if defined?(Rails)
        Rails.application
      else
        nil
      end
    }

    add_setting :curl_host, :default => nil
    add_setting :keep_source_order, :default => false
    add_setting :api_name, :default => "API Documentation"

    def settings
      @settings ||= {}
    end

    def each(&block)
      yield self
      groups.map { |g| g.each &block }
    end
  end
end
