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

    # Defines a new sub configuration
    #
    # Automatically sets the `filter` to the group name, and the `docs_dir` to
    # a subfolder of the parent's `doc_dir` named the group name.
    #
    #   RspecApiDocumentation.configure do |config|
    #     config.docs_dir = "doc/api"
    #     config.define_group(:public) do |config|
    #       # Default values
    #       config.docs_dir = "doc/api/public"
    #       config.filter = :public
    #     end
    #   end
    #
    # Params:
    # +name+:: String name of the group
    # +block+:: Block configuration block
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

    add_setting :configurations_dir, :default => lambda { |config|
      if defined?(Rails)
        Rails.root.join('doc', 'configurations', 'api')
      else
        Pathname.new('doc/configurations/api')
      end
    }

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

    add_setting :curl_headers_to_filter, :default => nil
    add_setting :curl_host, :default => nil
    add_setting :keep_source_order, :default => false
    add_setting :api_name, :default => "API Documentation"
    add_setting :api_explanation, :default => nil
    add_setting :io_docs_protocol, :default => "http"
    add_setting :request_headers_to_include, :default => nil
    add_setting :response_headers_to_include, :default => nil
    add_setting :html_embedded_css_file, :default => nil

    # renamed to request_body_formatter. here for backwards compatibility
    add_setting :post_body_formatter, :default => nil

    # Change how the post body is formatted by default, you can still override by `raw_post`
    # Can be :json, :xml, or a proc that will be passed the params
    #
    #   RspecApiDocumentation.configure do |config|
    #     config.request_body_formatter = Proc.new do |params|
    #       # convert to whatever you want
    #       params.to_s
    #     end
    #   end
    #
    # See RspecApiDocumentation::DSL::Endpoint#do_request
    add_setting :request_body_formatter, :default => Proc.new { |_| RspecApiDocumentation.configuration.post_body_formatter || Proc.new { |params| params } }

    # Change how the response body is formatted
    # Can be a proc that will be passed the response body
    #
    #   RspecApiDocumentation.configure do |config|
    #     config.response_body_formatter = Proc.new do |content_type, response_body|
    #       # convert to whatever you want
    #       response_body
    #     end
    #   end
    #
    # See RspecApiDocumentation::DSL::Endpoint#do_request
    add_setting :response_body_formatter, default: Proc.new { |_, _|
      Proc.new do |content_type, response_body|
        if response_body.encoding == Encoding::ASCII_8BIT
          "[binary data]"
        elsif content_type =~ /application\/.*json/
          JSON.pretty_generate(JSON.parse(response_body))
        else
          response_body
        end
      end
    }

    def client_method=(new_client_method)
      return if new_client_method == client_method

      RspecApiDocumentation::DSL::Resource.module_eval <<-RUBY
        alias :#{new_client_method} #{client_method}
        undef #{client_method}
      RUBY

      @client_method = new_client_method
    end

    def client_method
      @client_method ||= :client
    end

    def disable_dsl_status!
      RspecApiDocumentation::DSL::Endpoint.module_eval <<-RUBY
        undef status
      RUBY
    end

    def disable_dsl_method!
      RspecApiDocumentation::DSL::Endpoint.module_eval <<-RUBY
        undef method
      RUBY
    end

    def settings
      @settings ||= {}
    end

    # Yields itself and sub groups to hook into the Enumerable module
    def each(&block)
      yield self
      groups.map { |g| g.each &block }
    end
  end
end
