require "coderay"

module RspecApiDocumentation
  module Syntax
    private

    def highlight_syntax(body, content_type, is_query_string = false)
      return if body.blank?
      begin
        case content_type
          when /json/
            CodeRay.scan(JSON.pretty_generate(JSON.parse(body)), :json).div
          when /html/
            CodeRay.scan(body, :html).div
          when /javascript/
            CodeRay.scan(body, :java_script).div
          when /xml/
            CodeRay.scan(body, :xml).div
          else
            body = prettify_request_body(body) if is_query_string
            "<pre>#{body}</pre>"
        end
      rescue Exception => e
        "<pre>#{e.inspect}</pre>"
      end
    end

    def prettify_request_body(string)
      return if string.blank?
      CGI.unescape(string.split("&").join("\n"))
    end
  end
end
