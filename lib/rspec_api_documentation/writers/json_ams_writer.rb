require 'rspec_api_documentation/writers/formatter'

module RspecApiDocumentation
  module Writers
    class JsonAmsWriter < Writer
      delegate :docs_dir, :to => :configuration

      def write
        write_index
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
        @json_api_index ||= JsonAmsIndex.new(index, configuration)
      end

    #   def write_example(example)
    #     JsonApiExample.new(example, configuration).write
    #   end
    #
    #   def write_examples
    #     index.examples.each do |example|
    #       write_example(example)
    #     end
    #   end
    end

    class JsonAmsIndex
      RESOURCE_TYPE = 'section'

      def initialize(index, configuration)
        @index = index
        @configuration = configuration
      end

      def as_json(_opts = nil)
        {
          meta: meta,
          sections: data,
        }
      end

      def meta
        {
          section_count: sections.count,
          example_count: examples.count
        }
      end

      def data
        sections.map { |section| section_hash(section) }
      end

      # data resources:
      def section_hash(section)
        {
          id: section_id(section),
          name: section[:resource_name],
          examples_json: section_examples(section),
          examples: json_examples,
        }
      end

      def section_examples(section)
        section[:examples].map do |example|
          JsonAmsExample.new(example, @configuration).as_json
        end
      end

      def section_id(section)
        section[:resource_name]
      end

      def sections
        @sections ||= IndexHelper.sections(examples, @configuration)
      end

      #
      ## included
      #
    end

    class JsonAmsExample
      attr_accessor :configuration
      delegate :docs_dir, to: :configuration

      def initialize(example, configuration)
        @configuration = configuration
        @example = example
        @host = configuration.curl_host
        @filter_headers = configuration.curl_headers_to_filter
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

      # remove all . to make valid id.
      def id
        basename.gsub('.', '-')
      end

      def as_json(_opts = nil)
        {
          id: id,
          resource: resource_name,
          http_method: http_method,
          route: route,
          description: description,
          explanation: explanation,
          parameters: potential_parameters,
          response_fields: potential_response_fields,
          # TODO: move this to own object
          requests: requests
        }
      end

      def potential_parameters
        respond_to?(:parameters) ? parameters : []
      end

      def potential_response_fields
        respond_to?(:response_fields) ? response_fields : []
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
          hash.merge!(id: hash[:request_path])
          hash
        end
      end
    end
  end
end
