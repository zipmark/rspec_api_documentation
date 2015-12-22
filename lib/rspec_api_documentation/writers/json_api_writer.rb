require 'rspec_api_documentation/writers/formatter'

module RspecApiDocumentation
  module Writers
    class JsonApiWriter < Writer
      delegate :docs_dir, :to => :configuration

      def write
        write_index
        write_examples
      end

      def write_index
        File.open(docs_dir.join("index.json"), "w+") do |f|
          f.write json_index
        end
      end

      def json_index
        Formatter.to_json(json_api_index)
      end

      def json_api_index
        @json_api_index ||= JsonApiIndex.new(index, configuration)
      end

      def write_example
        JsonApiExample.new(example, configuration).write
      end

      def write_examples
        index.examples.each do |example|
          write_example(example)
        end
      end
    end

    class JsonApiIndex
      def initialize(index, configuration)
        @index = index
        @configuration = configuration
      end

      def sections
        @sections ||= IndexHelper.sections(examples, @configuration)
      end

      def examples
        @examples ||= @index.examples.map do |example|
          JsonApiExample.new(example, @configuration)
        end
      end

      def meta
        {
          count: sections.count,
          example_count: examples.count
        }
      end

      def included_resources
        # [TODO] add examples, parameters, requests, response_fields
        []
      end

      def data
        sections.map { |section| section_hash(section) }
      end

      def as_json(_opts = nil)
        {
          meta: meta,
          data: data,
          included: included_resources
        }
      end

      def section_hash(section)
        {
          type: 'resource',
          id: Digest::SHA1.hexdigest(section.to_s),
          attributes: {
            name: section[:resource_name],
          },
          examples: section[:examples].map { |example| example.as_json }
        }
      end
    end

    class JsonApiExample
      attr_accessor :configuration
      delegate :docs_dir, to: :configuration

      def initialize(example, configuration)
        @configuration = configuration
        @example = example
        @host = configuration.curl_host
        @filter_headers = configuration.curl_headers_to_filter
      end

      def write
        FileUtils.mkdir_p(docs_dir.join(dirname))
        File.open(file_path, "w+") do |f|
          f.write Formatter.to_json(self)
        end
      end

      def file_path
        docs_dir.join(dirname, filename)
      end

      def method_missing(method, *args, &block)
        @example.send(method, *args, &block)
      end

      def respond_to?(method, include_private = false)
        super || @example.respond_to?(method, include_private)
      end

      def dirname
        resource_name.to_s.downcase.gsub(/\s+/, '_').sub(/^\//,'')
      end

      def basename
        description.downcase.gsub(/\s+/, '_').gsub(Pathname::SEPARATOR_PAT, '')
      end

      def filename
        "#{basename}.json"
      end

      def as_json(_opts = nil)
        {
          type: 'example',
          id: Digest::SHA1.hexdigest(basename),
          attributes: {
            resource: resource_name,
            http_method: http_method,
            route: route,
            description: description,
            explanation: explanation,
            parameters: respond_to?(:parameters) ? parameters : [],
            response_fields: respond_to?(:response_fields) ? response_fields : [],
            # TODO: move this to own object
            :requests => requests
          }
        }
      end

      def requests
        super.map do |hash|
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
    end
  end
end
