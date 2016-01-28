module RspecApiDocumentation::DSL
  # DSL methods available at the example group level
  module Resource
    extend ActiveSupport::Concern

    module ClassMethods
      def self.define_action(method)
        define_method method do |*args, &block|
          options = args.extract_options!
          options[:method] = method
          options[:route] = args.first
          options[:api_doc_dsl] = :endpoint
          args.push(options)
          args[0] = "#{method.to_s.upcase} #{args[0]}"
          context(*args, &block)
        end
      end

      define_action :get
      define_action :post
      define_action :put
      define_action :delete
      define_action :head
      define_action :patch

      def callback(*args, &block)
        begin
          require 'webmock'
        rescue LoadError
          raise "Callbacks require webmock to be installed"
        end
        self.send(:include, WebMock::API)

        options = if args.last.is_a?(Hash) then args.pop else {} end
        options[:api_doc_dsl] = :callback
        args.push(options)

        context(*args, &block)
      end

      def parameter(name, *args)
        parameters.push(field_specification(name, *args))
      end

      def response_field(name, *args)
        response_fields.push(field_specification(name, *args))
      end

      def header(name, value)
        headers[name] = value
      end

      def explanation(text)
        safe_metadata(:resource_explanation, text)
      end

      private

      def field_specification(name, *args)
        options = args.extract_options!
        description = args.pop || "#{Array(options[:scope]).join(" ")} #{name}".humanize

        options.merge(:name => name.to_s, :description => description)
      end

      def safe_metadata(field, default)
        metadata[field] ||= default
        if superclass_metadata && metadata[field].equal?(superclass_metadata[field])
          metadata[field] = Marshal.load(Marshal.dump(superclass_metadata[field]))
        end
        metadata[field]
      end

      def parameters
        safe_metadata(:parameters, [])
      end

      def response_fields
        safe_metadata(:response_fields, [])
      end

      def headers
        safe_metadata(:headers, {})
      end

      def parameter_keys
        parameters.map { |param| param[:name] }
      end
    end

    def app
      RspecApiDocumentation.configuration.app
    end

    def client
      @client ||= RspecApiDocumentation::RackTestClient.new(self)
    end

    def no_doc(&block)
      requests = example.metadata[:requests]
      example.metadata[:requests] = []

      instance_eval(&block)

      example.metadata[:requests] = requests
    end
  end
end
