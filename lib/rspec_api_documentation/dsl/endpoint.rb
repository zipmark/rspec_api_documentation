require 'rspec/core/formatters/base_formatter'

module RspecApiDocumentation::DSL
  module Endpoint
    extend ActiveSupport::Concern

    delegate :response_headers, :status, :response_status, :response_body, :to => :client

    module ClassMethods
      def example_request(description, params = {}, &block)
        file_path = caller.first[0, caller.first =~ /:/]

        location = caller.first[0, caller.first =~ /(:in|$)/]
        location = relative_path(location)

        example description, :location => location, :file_path => file_path do
          do_request(params)
          instance_eval &block if block_given?
        end
      end

      private
      # from rspec-core
      def relative_path(line)
        line = line.sub(File.expand_path("."), ".")
        line = line.sub(/\A([^:]+:\d+)$/, '\\1')
        return nil if line == '-e:1'
        line
      end
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

      client.send(method, path_or_query, params_or_body, headers)
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

    def headers
      example.metadata[:headers]
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
