require 'rack/test/methods'
require 'rack'
require 'webmock'

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

      def callback(description, &block)
        self.send(:include, WebMock::API)
        context(description, &block)
      end

      def trigger_callback(&block)
        define_method(:do_callback) do
          stub_request(:any, callback_url).to_rack(destination)
          instance_eval &block
        end
      end
    end

    module InstanceMethods
      def client
        @client ||= TestClient.new(self)
      end

      def destination
        @destination ||= TestServer.new(self)
      end

      def callback_url
        raise "You must define callback_url"
      end

      def do_request
        params_or_body = nil
        path_or_query = path

        if method == :get && !query_string.blank?
          path_or_query = path + "?#{query_string}"
        else
          params_or_body = respond_to?(:raw_post) ? raw_post : params
        end

        client.send(method, path_or_query, params_or_body)
      end

      def query_string
        query = params.to_a.map do |param|
          param.map! { |a| CGI.escape(a.to_s) }
          param.join("=")
        end
        query.join("&")
      end

      def params
        return unless example.metadata[:parameters]
        example.metadata[:parameters].inject({}) do |h, param|
          k = param[:name]
          h[k] = send(k) if respond_to?(k) && !in_path?(k)
          h
        end
      end

      def method
        example.metadata[:method]
      end

      def in_path?(param)
        path_params.include?(param)
      end

      def path_params
        example.metadata[:path].scan(/:(\w+)/).flatten
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
