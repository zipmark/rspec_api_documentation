require 'active_support/core_ext/object/to_query'

module RspecApiDocumentation

  class Curl < Struct.new(:method, :path, :data, :headers)
    attr_accessor :host

    def output(config_host, config_headers_to_filter = nil, config_filter_empty_headers = false)
      self.host = config_host
      @config_headers_to_filter = config_headers_to_filter
      @config_filter_empty_headers = config_filter_empty_headers
      
      append_filters

      send(method.downcase)
    end

    def self.format_header(header)
      header.gsub(/^HTTP_/, '').titleize.split.join("-")
    end

    def post
      "curl \"#{url}\" #{post_data} -X POST #{headers}"
    end

    def get
      "curl \"#{url}#{get_data}\" -X GET #{headers}"
    end

    def head
      "curl \"#{url}#{get_data}\" -X HEAD #{headers}"
    end

    def put
      "curl \"#{url}\" #{post_data} -X PUT #{headers}"
    end

    def delete
      "curl \"#{url}\" #{post_data} -X DELETE #{headers}"
    end

    def patch
      "curl \"#{url}\" #{post_data} -X PATCH #{headers}"
    end

    def url
      "#{host}#{path}"
    end

    def headers
      filter_headers(super).map do |k, v|
        "\\\n\t-H \"#{format_full_header(k, v)}\""
      end.join(" ")
    end

    def get_data
      "?#{data}" unless data.blank?
    end

    def post_data
      escaped_data = data.to_s.gsub("'", "\\u0027")
      "-d '#{escaped_data}'"
    end

    private

    def append_filters
      @filters = Array.new
      @filters << ConfiguredHeadersFilter.new(@config_headers_to_filter) if @config_headers_to_filter
      @filters << EmptyHeaderFilter.new if @config_filter_empty_headers
    end

    def format_full_header(header, value)
      formatted_value = value ? value.gsub(/"/, "\\\"") : ''
      "#{Curl.format_header(header)}: #{formatted_value}"
    end

    def filter_headers(headers)
      @filters.inject(headers) do |headers, filter|
        filter.call(headers)
      end
    end
  end

  class EmptyHeaderFilter
    def call(headers)
      headers.reject do |header, value|
        value.blank?
      end
    end
  end

  class ConfiguredHeadersFilter

    def initialize(headers_to_filter)
      @headers_to_filter = Array(headers_to_filter)
    end

    def call(headers)
      headers.reject do |header|
        @headers_to_filter.include?(Curl.format_header(header))
      end
    end
  end
end
