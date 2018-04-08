require 'mustache'

module RspecApiDocumentation
  module Views
    class MarkupExample < Mustache
      SPECIAL_CHARS = /[<>:"\/\\|?*]/.freeze

      def initialize(example, configuration)
        @example = example
        @host = configuration.curl_host
        @filter_headers = configuration.curl_headers_to_filter
        self.template_path = configuration.template_path
      end

      def method_missing(method, *args, &block)
        @example.send(method, *args, &block)
      end

      def respond_to?(method, include_private = false)
        super || @example.respond_to?(method, include_private)
      end

      def dirname
        sanitize(resource_name.to_s.downcase)
      end

      def filename
        basename = sanitize(description.downcase)
        basename = Digest::MD5.new.update(description).to_s if basename.blank?
        "#{basename}.#{extension}"
      end

      def parameters
        super.each do |parameter|
          if parameter.has_key?(:scope)
            parameter[:scope] = format_scope(parameter[:scope])
          end
        end
      end

      def response_fields
        super.each do |response_field|
          if response_field.has_key?(:scope)
            response_field[:scope] = format_scope(response_field[:scope])
          end
        end
      end

      def requests
        super.map do |hash|
          hash[:request_headers_text] = format_hash(hash[:request_headers])
          hash[:request_query_parameters_text] = format_hash(hash[:request_query_parameters])
          hash[:response_headers_text] = format_hash(hash[:response_headers])
          if @host
            if hash[:curl].is_a? RspecApiDocumentation::Curl
              hash[:curl] = hash[:curl].output(@host, @filter_headers)
            end
          else
            hash[:curl] = nil
          end
          hash
        end
      end

      def extension
        raise 'Parent class. This method should not be called.'
      end

      private

      def format_hash(hash = {})
        return nil unless hash.present?
        hash.collect do |k, v|
          "#{k}: #{v}"
        end.join("\n")
      end

      def format_scope(unformatted_scope)
        Array(unformatted_scope).each_with_index.map do |scope, index|
          if index == 0
            scope
          else
            "[#{scope}]"
          end
        end.join
      end

      def content_type(headers)
        headers && headers.fetch("Content-Type", nil)
      end

      def sanitize(name)
        name.gsub(/\s+/, '_').gsub(SPECIAL_CHARS, '')
      end
    end
  end
end
