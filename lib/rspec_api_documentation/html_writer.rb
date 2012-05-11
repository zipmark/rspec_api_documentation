require 'mustache'

module RspecApiDocumentation
  class HtmlWriter
    attr_accessor :index, :configuration

    def initialize(index, configuration)
      self.index = index
      self.configuration = configuration
    end

    def self.write(index, configuration)
      writer = new(index, configuration)
      writer.write
    end

    def write
      File.open(configuration.docs_dir.join("index.html"), "w+") do |f|
        f.write HtmlIndex.new(index, configuration).render
      end

      index.examples.each do |example|
        html_example = HtmlExample.new(example, configuration)
        FileUtils.mkdir_p(configuration.docs_dir.join(html_example.dirname))
        File.open(configuration.docs_dir.join(html_example.dirname, html_example.filename), "w+") do |f|
          f.write html_example.render
        end
      end
    end
  end

  class HtmlIndex < Mustache
    def initialize(index, configuration)
      @index = index
      @configuration = configuration
      self.template_path = configuration.template_path
    end

    def sections
      IndexWriter.sections(examples, @configuration)
    end

    def examples
      @index.examples.map { |example| HtmlExample.new(example, @configuration) }
    end
  end

  class HtmlExample < Mustache
    def initialize(example, configuration)
      @example = example
      @host = configuration.curl_host
      self.template_path = configuration.template_path
    end

    def method_missing(method, *args, &block)
      @example.send(method, *args, &block)
    end

    def respond_to?(method, include_private = false)
      super || @example.respond_to?(method, include_private)
    end

    def dirname
      resource_name.downcase.gsub(/\s+/, '_')
    end

    def filename
      basename = description.downcase.gsub(/\s+/, '_').gsub(/[^a-z_]/, '')
      "#{basename}.html"
    end

    def requests

      super.collect do |hash|
        hash[:request_headers_hash] = hash[:request_headers].collect {|k,v| {:name => k, :value => v}}
        hash[:request_headers_text] = format_hash(hash[:request_headers])
        hash[:request_path_no_query] = hash[:request_path].split('?').first
        hash[:request_query_parameters_text] = format_hash(hash[:request_query_parameters])
        hash[:request_query_parameters_hash] = hash[:request_query_parameters].collect { |k, v| {:name => k, :value => v} } if hash[:request_query_parameters].present?
        hash[:response_headers_text] = format_hash(hash[:response_headers])
        hash[:response_status] = hash[:response_status].to_s + " " + Rack::Utils::HTTP_STATUS_CODES[hash[:response_status]].to_s
        if @host
          hash[:curl] = hash[:curl].output(@host) if hash[:curl].is_a? RspecApiDocumentation::Curl
        else
          hash[:curl] = nil
        end
        hash
      end
    end

    def url_prefix
      configuration.url_prefix
    end

    private
    def format_hash(hash = {})
      return "" unless hash.present?
      hash.collect do |k,v|
        "#{k}: #{v}"
      end.join("\n")
    end
  end
end
