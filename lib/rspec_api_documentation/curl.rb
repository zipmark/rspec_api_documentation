module RspecApiDocumentation
  class Curl < Struct.new(:method, :host, :path, :data, :headers)
    def output
      send(method.downcase)
    end

    def post
      "curl #{post_data} #{url} -X POST #{headers}"
    end

    def get
      "curl #{url}?#{data.to_query} -X GET #{headers}"
    end

    def put
      "curl #{post_data} #{url} -X PUT #{headers}"
    end

    def delete
      "curl #{url} -X DELETE #{headers}"
    end

    def url
      "#{host}#{path}"
    end

    def headers
      super.map do |k, v|
        "-H \"#{format_header(k, v)}\""
      end.join(" ")
    end

    def post_data
      "-d \"" + data.to_query.split("&").join("\" -d \"") + "\""
    end

    private
    def format_header(header, value)
      formatted_header = header.gsub(/^HTTP_/, '').titleize.split.join("-")
      "#{formatted_header}: #{value}"
    end
  end
end
