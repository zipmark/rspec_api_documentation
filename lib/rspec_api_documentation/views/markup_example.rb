require 'mustache'
require 'json'
require 'uri'

module RspecApiDocumentation
  module Views
    class MarkupExample < Mustache
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
        resource_name.downcase.gsub(/\s+/, '_').gsub(":", "_")
      end

      def filename
        basename = description.downcase.gsub(/\s+/, '_').gsub(Pathname::SEPARATOR_PAT, '')
        basename = Digest::MD5.new.update(description).to_s if basename.blank?
        "#{basename}.#{extension}"
      end

      def requests
        super.map do |hash|
          hash[:request_headers_text] = format_hash(hash[:request_headers])
          hash[:request_query_parameters_text] = format_hash(hash[:request_query_parameters])
          hash[:response_headers_text] = format_hash(hash[:response_headers])
          hash[:response_body] = JSON.pretty_generate(JSON.parse(hash[:response_body])) rescue nil
          # puts "requst body: #{hash[:request_body]}"
          # puts "uri decode: #{URI.decode_www_form(hash[:request_body])}" rescue nil
          # puts "uri decode hash: #{Hash[URI.decode_www_form(hash[:request_body])]}" rescue nil
          # puts "uri decode hash: #{Hash[URI.decode_www_form(hash[:request_body])].to_json}" rescue nil
          # puts "pretty: #{JSON.pretty_generate(Hash[URI.decode_www_form(hash[:request_body])].to_json)}"
          rb_hash = Hash[URI.decode_www_form(hash[:request_body])] rescue nil
          # puts "rb_hash: #{rb_hash}"
          # puts "pretty: #{JSON.pretty_generate(rb_hash)}" rescue nil
          hash[:request_body] = JSON.pretty_generate(rb_hash) rescue nil
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
    end
  end
end
