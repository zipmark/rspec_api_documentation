require 'rack/test'
require 'webmock'
require 'rspec/core/formatters/base_formatter'

module RspecApiDocumentation
  module DSL
    extend ActiveSupport::Concern

    delegate :last_response_headers, :status, :response_body, :to => :client

    module ClassMethods
      def self.define_action(method)
        define_method method do |*args, &block|
          options = if args.last.is_a?(Hash) then args.pop else {} end
          options[:method] = method
          options[:route] = args.first
          args.push(options)
          args[0] = "#{method.to_s.upcase} #{args[0]}"
          context(*args, &block)
        end
      end

      define_action :get
      define_action :post
      define_action :put
      define_action :delete

      def parameter(name, description, options = {})
        parameters.push(options.merge(:name => name.to_s, :description => description))
      end

      def required_parameters(*names)
        names.each do |name|
          param = parameters.find { |param| param[:name] == name.to_s }
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

      def scope_parameters(scope, keys)
        return unless metadata[:parameters]

        if keys == :all
          keys = parameter_keys.map(&:to_s)
        else
          keys = keys.map(&:to_s)
        end

        keys.each do |key|
          param = parameters.detect { |param| param[:name] == key }
          param[:scope] = scope if param
        end
      end

      def example_request(description, params = {}, &block)
        file_path = caller.first[0, caller.first =~ /:/]

        location = caller.first[0, caller.first =~ /(:in|$)/]
        location = RSpec::Core::Formatters::BaseFormatter::relative_path(location)

        example description, :location => location, :file_path => file_path do
          do_request(params)
          instance_eval &block if block_given?
        end
      end

      private
      def parameters
        metadata[:parameters] ||= []
        if superclass_metadata && metadata[:parameters].equal?(superclass_metadata[:parameters])
          metadata[:parameters] = Marshal.load(Marshal.dump(superclass_metadata[:parameters]))
        end
        metadata[:parameters]
      end

      def parameter_keys
        parameters.map { |param| param[:name] }
      end
    end

    def client
      @client ||= TestClient.new(self)
    end

    def destination
      @destination ||= TestServer.new(self)
    end

    def callback_url
      raise "You must define callback_url"
    end

    def do_request(extra_params = {})
      @extra_params = extra_params

      params_or_body = nil
      path_or_query = path

      if method == :get && !query_string.blank?
        path_or_query = path + "?#{query_string}"
      else
        params_or_body = respond_to?(:raw_post) ? raw_post : params
      end

      client.send(method, path_or_query, params_or_body)
    end

    def no_doc(&block)
      requests = example.metadata[:requests]
      example.metadata[:requests] = []

      instance_eval &block

      example.metadata[:requests] = requests
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
      parameters = example.metadata[:parameters].inject({}) do |hash, param|
        set_param(hash, param)
      end
      parameters.merge!(extra_params)
      parameters
    end

    def method
      example.metadata[:method]
    end

    def in_path?(param)
      path_params.include?(param)
    end

    def path_params
      example.metadata[:route].scan(/:(\w+)/).flatten
    end

    def path
      example.metadata[:route].gsub(/:(\w+)/) do |match|
        if extra_params.keys.include?($1)
          delete_extra_param($1)
        elsif respond_to?($1)
          send($1)
        else
          match
        end
      end
    end

    def app
      RspecApiDocumentation.configuration.app
    end

    def explanation(text)
      example.metadata[:explanation] = text
    end

    private
    def extra_params
      return {} if @extra_params.nil?
      @extra_params.inject({}) do |h, (k, v)|
        h[k.to_s] = v
        h
      end
    end

    def delete_extra_param(key)
      @extra_params.delete(key.to_sym) || @extra_params.delete(key.to_s)
    end

    def set_param(hash, param)
      key = param[:name]
      return hash if !respond_to?(key) || in_path?(key)

      if param[:scope]
        hash[param[:scope].to_s] ||= {}
        hash[param[:scope].to_s][key] = send(key)
      else
        hash[key] = send(key)
      end

      hash
    end
  end
end

def self.resource(*args, &block)
  options = if args.last.is_a?(Hash) then args.pop else {} end
  options[:api_docs_dsl] = true
  options[:resource_name] = args.first
  options[:document] ||= :all
  args.push(options)
  describe(*args, &block)
end

RSpec.configuration.include RspecApiDocumentation::DSL, :api_docs_dsl => true
RSpec.configuration.backtrace_clean_patterns << %r{lib/rspec_api_documentation/dsl\.rb}
