module RspecApiDocumentation
  module Headers
    private

    def env_to_headers(env)
      headers = {}
      env.each do |key, value|
        # HTTP_ACCEPT_CHARSET => Accept-Charset
        if key =~ /^(HTTP_|CONTENT_TYPE)/
          header = key.gsub(/^HTTP_/, '').split('_').map{|s| s.titleize}.join("-")
          headers[header] = value
        end
      end
      headers
    end

    def headers_to_env(headers)
      headers.inject({}) do |hsh, (k, v)|
        new_key = k.upcase.gsub("-", "_")
        new_key = "HTTP_#{new_key}" unless new_key == "CONTENT_TYPE"
        hsh[new_key] = v
        hsh
      end
    end

    def format_headers(headers)
      headers.map do |key, value|
        "#{key}: #{value}"
      end.join("\n")
    end
  end
end
