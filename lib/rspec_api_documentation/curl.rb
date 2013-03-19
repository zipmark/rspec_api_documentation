require 'active_support/core_ext/object/to_query'

module RspecApiDocumentation
  class Curl < Struct.new(:method, :path, :data, :headers)
    attr_accessor :host

    def output(config_host)
      self.host = config_host
      send(method.downcase)
    end

    def post
      "curl \"#{url}\" #{post_data} -X POST #{headers}"
    end

    def get
      "curl \"#{url}#{get_data}\" -X GET #{headers}"
    end

    def put
      "curl \"#{url}\" #{post_data} -X PUT #{headers}"
    end

    def delete
      "curl \"#{url}\" #{post_data} -X DELETE #{headers}"
    end

    def url
      "#{host}#{path}"
    end

    def headers
      super.map do |k, v|
        "-H \"#{format_header(k, v)}\""
      end.join(" ")
    end

    def get_data
      "?#{data}" unless data.blank?
    end

    def post_data
      escaped_data = data.gsub("'", "\\u0027")
      "-d '#{escaped_data}'"
    end

    private
    def format_header(header, value)
      formatted_header = header.gsub(/^HTTP_/, '').titleize.split.join("-")
      "#{formatted_header}: #{value}"
    end
  end
end
