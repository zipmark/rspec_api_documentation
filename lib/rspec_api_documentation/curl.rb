require 'active_support/core_ext/object/to_query'
require 'multipart_parser/reader'

module RspecApiDocumentation
  class Curl < Struct.new(:method, :path, :data, :headers)
    attr_accessor :host

    def output(config_host, config_headers_to_filer = nil)
      self.host = config_host
      @config_headers_to_filer = Array(config_headers_to_filer)
      send(method.downcase)
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

    alias :original_headers :headers

    def is_multipart?
      original_headers["Content-Type"].try(:match, /\Amultipart\/form-data/)
    end

    def headers
      filter_headers(super).reject{ |k, v| k.eql?("Content-Type") && v.match(/multipart\/form-data/) }.map do |k, v|
        "\\\n\t-H \"#{format_full_header(k, v)}\""
      end.join(" ")
    end

    def get_data
      "?#{data}" unless data.blank?
    end

    def post_data
      if is_multipart?
        boundary = MultipartParser::Reader.extract_boundary_value(original_headers["Content-Type"])
        reader = MultipartParser::Reader.new(boundary)
        flags = []
        reader.on_part do |part|
          value = ""
          unless part.filename.nil?
            value = "@#{part.filename};type=#{part.mime}"
          else
            part.on_data do |data|
              value += data
            end
          end
          part.on_end do
            flags.push "-F '#{part.name}=#{value.gsub("'", "\\u0027")}'"
          end
        end
        reader.write(data.to_s)
        flags.join(" ")
      else
        escaped_data = data.to_s.gsub("'", "\\u0027")
        "-d '#{escaped_data}'"
      end
    end

    private

    def format_header(header)
      header.gsub(/^HTTP_/, '').titleize.split.join("-")
    end

    def format_full_header(header, value)
      formatted_value = value.gsub(/"/, "\\\"")
      "#{format_header(header)}: #{formatted_value}"
    end

    def filter_headers(headers)
      if !@config_headers_to_filer.empty?
        headers.reject do |header|
          @config_headers_to_filer.include?(format_header(header))
        end
      else
        headers
      end
    end
  end
end
