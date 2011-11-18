require 'rack/test/methods'

module RspecApiDocumentation
  module DSL
    extend ActiveSupport::Concern

    module ClassMethods
      def self.define_action(method)
        define_method method do |*args, &block|
          options = if args.last.is_a?(Hash) then args.pop else {} end
          options[:method] = method
          options[:path] = args.first
          args.push(options)
          args[0] = "#{method.to_s.upcase} #{args[0]}"
          context(*args, &block)
        end
      end

      define_action :get
      define_action :post
      define_action :put
      define_action :delete

      def parameter(name, description)
        metadata[:parameters] ||= []
        if superclass_metadata && metadata[:parameters].equal?(superclass_metadata[:parameters])
          metadata[:parameters] = superclass_metadata[:parameters].clone
        end
        metadata[:parameters].push(:name => name.to_s, :description => description)
      end

      def required_parameters(*names)
        names.each do |name|
          param = metadata[:parameters].find { |param| param[:name] == name.to_s }
          raise "Undefined parameters can not be required." unless param
          param[:required] = true
        end
      end
    end

    module InstanceMethods
      def client
        @client ||= TestClient.new(self)
      end

      def do_request
        params_or_body = respond_to?(:raw_post) ? raw_post : params
        client.send(method, path, params_or_body)
      end

      def params
        return unless example.metadata[:parameters]
        example.metadata[:parameters].inject({}) do |h, param|
          k = param[:name]
          h[k] = send(k) if respond_to?(k)
          h
        end
      end

      def method
        example.metadata[:method]
      end

      def path
        example.metadata[:path].gsub(/:(\w+)/) do |match|
          if respond_to?($1)
            send($1)
          else
            match
          end
        end
      end
    end
  end
end

def self.resource(*args, &block)
  options = if args.last.is_a?(Hash) then args.pop else {} end
  options[:api_docs_dsl] = true
  options[:resource_name] = args.first
  options[:document] = true
  args.push(options)
  describe(*args, &block)
end

RSpec.configuration.include RspecApiDocumentation::DSL, :api_docs_dsl => true
RSpec.configuration.include Rack::Test::Methods, :api_docs_dsl => true
