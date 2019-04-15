require 'rspec_api_documentation/writers/formatter'
require 'yaml'

module RspecApiDocumentation
  module Writers
    class OpenApiWriter < Writer
      FILENAME = 'open_api'

      delegate :docs_dir, :configurations_dir, to: :configuration

      def write
        File.open(docs_dir.join("#{FILENAME}.json"), 'w+') do |f|
          f.write Formatter.to_json(OpenApiIndex.new(index, configuration, load_config))
        end
      end

      private

      def load_config
        return JSON.parse(File.read("#{configurations_dir}/open_api.json")) if File.exist?("#{configurations_dir}/open_api.json")
        YAML.load_file("#{configurations_dir}/open_api.yml") if File.exist?("#{configurations_dir}/open_api.yml")
      end
    end

    class OpenApiIndex
      attr_reader :index, :configuration, :init_config

      def initialize(index, configuration, init_config)
        @index = index
        @configuration = configuration
        @init_config = init_config
      end

      def as_json
        @specs = OpenApi::Root.new(init_config)
        add_tags!
        add_paths!
        add_security_definitions!
        specs.as_json
      end

      private

      attr_reader :specs

      def examples
        index.examples.map { |example| OpenApiExample.new(example) }
      end

      def add_security_definitions!
        security_definitions = OpenApi::SecurityDefinitions.new

        arr = examples.map do |example|
          example.respond_to?(:authentications) ? example.authentications : nil
        end.compact

        arr.each do |securities|
          securities.each do |security, opts|
            schema = OpenApi::SecuritySchema.new(
              name: opts[:name],
              description: opts[:description],
              type: opts[:type],
              in: opts[:in]
            )
            security_definitions.add_setting security, :value => schema
          end
        end
        specs.securityDefinitions = security_definitions unless arr.empty?
      end

      def add_tags!
        tags = {}
        examples.each do |example|
          tags[example.resource_name] ||= example.resource_explanation
        end
        specs.safe_assign_setting(:tags, [])
        tags.each do |name, desc|
          specs.tags << OpenApi::Tag.new(name: name, description: desc) unless specs.tags.any? { |tag| tag.name == name }
        end
      end

      def add_paths!
        specs.safe_assign_setting(:paths, OpenApi::Paths.new)
        examples.each do |example|
          specs.paths.add_setting example.route, :value => OpenApi::Path.new

          operation = specs.paths.setting(example.route).setting(example.http_method) || OpenApi::Operation.new

          operation.safe_assign_setting(:tags, [example.resource_name])
          operation.safe_assign_setting(:summary, example.respond_to?(:route_summary) ? example.route_summary : '')
          operation.safe_assign_setting(:description, example.respond_to?(:route_description) ? example.route_description : '')
          operation.safe_assign_setting(:responses, OpenApi::Responses.new)
          operation.safe_assign_setting(:parameters, extract_parameters(example))
          operation.safe_assign_setting(:consumes, example.requests.map { |request| request[:request_content_type] }.compact.map { |q| q[/[^;]+/] })
          operation.safe_assign_setting(:produces, example.requests.map { |request| request[:response_content_type] }.compact.map { |q| q[/[^;]+/] })
          operation.safe_assign_setting(:security, example.respond_to?(:authentications) ? example.authentications.map { |(k, _)| {k => []} } : [])

          process_responses(operation.responses, example)

          specs.paths.setting(example.route).assign_setting(example.http_method, operation)
        end
      end

      def process_responses(responses, example)
        schema = extract_schema(example.respond_to?(:response_fields) ? example.response_fields : [])
        example.requests.each do |request|
          response = OpenApi::Response.new(
            description: example.description,
            schema: schema
          )

          if request[:response_headers]
            response.safe_assign_setting(:headers, OpenApi::Headers.new)
            request[:response_headers].each do |header, value|
              response.headers.add_setting header, :value => OpenApi::Header.new('x-example-value' => value)
            end
          end

          if /\A(?<response_content_type>[^;]+)/ =~ request[:response_content_type]
            response.safe_assign_setting(:examples, OpenApi::Example.new)
            response_body = JSON.parse(request[:response_body]) rescue nil
            response.examples.add_setting response_content_type, :value => response_body
          end
          responses.add_setting "#{request[:response_status]}", :value => response
        end
      end

      def extract_schema(fields)
        schema = {type: 'object', properties: {}}

        fields.each do |field|
          current = schema
          if field[:scope]
            [*field[:scope]].each do |scope|
              current[:properties][scope] ||= {type: 'object', properties: {}}
              current = current[:properties][scope]
            end
          end
          current[:properties][field[:name]] = {type: field[:type] || OpenApi::Helper.extract_type(field[:value])}
          current[:properties][field[:name]][:example] = field[:value] if field[:value] && field[:with_example]
          current[:properties][field[:name]][:default] = field[:default] if field[:default]
          current[:properties][field[:name]][:description] = field[:description] if field[:description]

          opts = {enum: field[:enum], minimum: field[:minimum], maximum: field[:maximum]}

          if current[:properties][field[:name]][:type] == :array
            current[:properties][field[:name]][:items] = field[:items] || OpenApi::Helper.extract_items(field[:value][0], opts)
          else
            opts.each { |k, v| current[:properties][field[:name]][k] = v if v }
          end

          if field[:required]
            current[:required] ||= []
            current[:required] << field[:name]
          end
        end

        OpenApi::Schema.new(schema)
      end

      def extract_parameters(example)
        parameters = example.extended_parameters.uniq { |parameter| parameter[:name] }

        extract_known_parameters(parameters.select { |p| !p[:in].nil? }) +
          extract_unknown_parameters(example, parameters.select { |p| p[:in].nil? })
      end

      def extract_parameter(opts)
        OpenApi::Parameter.new(
          name:         opts[:name],
          in:           opts[:in],
          description:  opts[:description],
          required:     opts[:required],
          type:         opts[:type] || OpenApi::Helper.extract_type(opts[:value]),
          value:        opts[:value],
          with_example: opts[:with_example],
          default:      opts[:default],
          example:      opts[:example],
        ).tap do |elem|
          if elem.type == :array
            elem.items = opts[:items] || OpenApi::Helper.extract_items(opts[:value][0], { minimum: opts[:minimum], maximum: opts[:maximum], enum: opts[:enum] })
          else
            elem.minimum = opts[:minimum]
            elem.maximum = opts[:maximum]
            elem.enum    = opts[:enum]
          end
        end
      end

      def extract_unknown_parameters(example, parameters)
        if example.http_method == :get
          parameters.map { |parameter| extract_parameter(parameter.merge(in: :query)) }
        elsif parameters.any? { |parameter| !parameter[:scope].nil? }
          [OpenApi::Parameter.new(
            name:        :body,
            in:          :body,
            description: '',
            schema:      extract_schema(parameters)
          )]
        else
          parameters.map { |parameter| extract_parameter(parameter.merge(in: :formData)) }
        end
      end

      def extract_known_parameters(parameters)
        result = parameters.select { |parameter| %w(query path header formData).include?(parameter[:in].to_s) }
                   .map { |parameter| extract_parameter(parameter) }

        body = parameters.select { |parameter| %w(body).include?(parameter[:in].to_s) }

        result.unshift(
          OpenApi::Parameter.new(
            name: :body,
            in: :body,
            description: '',
            schema: extract_schema(body)
          )
        ) unless body.empty?

        result
      end
    end

    class OpenApiExample
      def initialize(example)
        @example = example
      end

      def method_missing(method, *args, &block)
        @example.send(method, *args, &block)
      end

      def respond_to?(method, include_private = false)
        super || @example.respond_to?(method, include_private)
      end

      def http_method
        metadata[:method]
      end

      def requests
        super.select { |request| request[:request_method].to_s.downcase == http_method.to_s.downcase }
      end

      def route
        super.gsub(/:(?<parameter>[^\/]+)/, '{\k<parameter>}')
      end
    end
  end
end
