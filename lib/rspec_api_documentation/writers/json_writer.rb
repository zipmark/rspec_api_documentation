require 'rspec_api_documentation/writers/formatter'

module RspecApiDocumentation
  module Writers
    class JSONWriter < Writer
      delegate :docs_dir, :to => :configuration

      def write
        File.open(docs_dir.join("index.json"), "w+") do |f|
          f.write Formatter.to_json(JSONIndex.new(index, configuration))
        end
        write_examples
      end

      def write_examples
        index.examples.each do |example|
          json_example = JSONExample.new(example, configuration)
          FileUtils.mkdir_p(docs_dir.join(json_example.dirname))
          File.open(docs_dir.join(json_example.dirname, json_example.filename), "w+") do |f|
            f.write Formatter.to_json(json_example)
          end
        end
      end
    end

    # https://github.com/zipmark/rspec_api_documentation/issues/382
    # backward compatibilty json for configuration of config.format
    class JsonWriter < JSONWriter; end

    class JSONIndex
      def initialize(index, configuration)
        @index = index
        @configuration = configuration
      end

      def sections
        IndexHelper.sections(examples, @configuration)
      end

      def examples
        @index.examples.map { |example| JSONExample.new(example, @configuration) }
      end

      def as_json(opts = nil)
        sections.inject({:resources => []}) do |h, section|
          h[:resources].push(section_hash(section))
          h
        end
      end

      def section_hash(section)
        {
          :name => section[:resource_name],
          :explanation => section[:resource_explanation],
          :examples => section[:examples].map { |example|
            {
              :description => example.description,
              :link => "#{example.dirname}/#{example.filename}",
              :groups => example.metadata[:document],
              :route => example.route,
              :method => example.metadata[:method]
            }
          }
        }
      end
    end

    class JSONExample
      def initialize(example, configuration)
        @example = example
        @host = configuration.curl_host
        @filter_headers = configuration.curl_headers_to_filter
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

      def filename
        basename = description.downcase.gsub(/\s+/, '_').gsub(Pathname::SEPARATOR_PAT, '')
        "#{basename}.json"
      end

      def as_json(opts = nil)
        {
          :resource => resource_name,
          :resource_explanation => resource_explanation,
          :http_method => http_method,
          :route => route,
          :description => description,
          :explanation => explanation,
          :parameters => respond_to?(:parameters) ? parameters : [],
          :response_fields => respond_to?(:response_fields) ? response_fields : [],
          :requests => requests
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
