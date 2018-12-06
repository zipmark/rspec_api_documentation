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
        add_components!
        add_tags!
        add_paths!
        add_security_schemes!
        specs.as_json
      end

      private

      attr_reader :specs

      def examples
        index.examples.map { |example| OpenApiExample.new(example) }
      end

      def add_components!
        specs.safe_assign_setting(:components, OpenApi::Components.new)
      end

      def add_security_schemes!
        security_schemes = {}

        arr = examples.map do |example|
          example.respond_to?(:authentications) ? example.authentications : nil
        end.compact

        arr.each do |securities|
          securities.each do |security, opts|
            schema = OpenApi::SecurityScheme.new(
              name: opts[:name],
              description: opts[:description],
              type: opts[:type],
              in: opts[:in]
            )
            security_schemes[security.to_s] = schema
          end
        end
        specs.components.safe_assign_setting(:securitySchemes, security_schemes) unless arr.empty?
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
        specs.safe_assign_setting(:paths, {})
        examples.each do |example|
          route = example.route.to_s
          specs.paths[route] ||= OpenApi::Path.new

          operation = specs.paths[route].setting(example.http_method) || OpenApi::Operation.new

          operation.safe_assign_setting(:tags, [example.resource_name])
          operation.safe_assign_setting(:summary, example.route_summary) if example.respond_to?(:route_summary)
          operation.safe_assign_setting(:description, example.route_description) if example.respond_to?(:route_description)
          operation.safe_assign_setting(:externalDocs, OpenApi::ExternalDocs.new(url: example.external_docs)) if example.respond_to?(:external_docs)
          operation.safe_assign_setting(:responses, {})
          operation.safe_assign_setting(:deprecated, example.deprecated) if example.respond_to?(:deprecated)
          operation.safe_assign_setting(:parameters, extract_parameters(example))
          operation.safe_assign_setting(:requestBody, extract_request_body(example))
          operation.safe_assign_setting(:security, example.respond_to?(:authentications) ? example.authentications.map { |(k, _)| {k => []} } : [])

          process_responses(operation.responses, example)

          specs.paths[route].assign_setting(example.http_method, operation)
        end
      end

      def process_responses(responses, example)
        schema = extract_schema(example.respond_to?(:response_fields) ? example.response_fields : nil)
        example.requests.each do |request|
          response = OpenApi::Response.new(
            description: example.description
          )

          if request[:response_headers]
            response.safe_assign_setting(:headers, {})
            request[:response_headers].each do |header, value|
              response.headers[header.to_s] = OpenApi::Header.new(schema: OpenApi::Schema.new(type: 'string'), example: value)
            end
          end

          response_body = JSON.parse(request[:response_body]) rescue nil
          if /\A(?<response_content_type>[^;]+)/ =~ request[:response_content_type]
            content_type = response_content_type.to_s
          else
            content_type = 'application/json'
          end

          if response_body
            response.safe_assign_setting(:content, {
              content_type => OpenApi::Media.new(schema: schema || get_schema(response_body), example: response_body)
            })
          end

          responses[request[:response_status].to_s] = response
        end
      end

      def extract_schema(fields)
        return nil if fields.nil?

        schema = { type: 'object', properties: {} }

        fields.each do |field|
          current = schema
          if field[:scope]
            [*field[:scope]].each do |scope|
              current[:properties][scope] ||= { type: 'object', properties: {} }
              current = current[:properties][scope]
            end
          end
          current[:properties][field[:name]] = { type: field[:type] || OpenApi::Helper.extract_type(field[:value]) }
          current[:properties][field[:name]][:example] = field[:value] if field[:value] && field[:with_example]

          opts = {
            description: field[:description],
            default: field[:default],
            enum: field[:enum],
            minimum: field[:minimum],
            maximum: field[:maximum],
            required: field[:required],
            nullable: field[:nullable] || field[:value].nil? || nil
          }

          if current[:properties][field[:name]][:type] == :array
            current[:properties][field[:name]][:items] = field[:items] || OpenApi::Helper.extract_items(field[:value][0], opts)
          else
            opts.each { |k, v| current[:properties][field[:name]][k] = v if v }
          end
        end

        OpenApi::Schema.new(schema)
      end

      def get_schema(field)
        type = OpenApi::Helper.extract_type(field).to_s
        case type
        when 'object'
          OpenApi::Schema.new(type: type, properties: Hash[field.map { |k, v| [k, get_schema(v)] }])
        when 'array'
          OpenApi::Schema.new(type: type, items: get_schema(field[0]))
        else
          OpenApi::Schema.new(type: type, example: field, nullable: field.nil? || nil)
        end
      end

      def extract_parameters(example)
        known_parameters = extract_known_parameters(example.extended_parameters.reject { |p| p[:in].nil? })
        known_param_names = known_parameters.map { |p| p.name }
        unknown_parameters = extract_unknown_parameters(example).reject { |p| known_param_names.include?(p.name) }
        known_parameters + unknown_parameters
      end

      def extract_request_body(example)
        if example.respond_to?(:request_body)
          OpenApi::RequestBody.new(
            content: {
              example.request_body[:type] || 'application/json' => OpenApi::Media.new(
                schema: OpenApi::Schema.new(example.request_body[:schema]),
                example: example.request_body[:example]
              )
            }
          )
        else
          body = example.requests.map { |req| JSON.parse(req[:request_body]) rescue nil }.compact.reduce({}, :merge)
          return nil if body.empty?

          OpenApi::RequestBody.new(
            content: {
              'application/json' => OpenApi::Media.new(schema: get_schema(body), example: body)
            }
          )
        end
      end

      def extract_parameter(opts)
        OpenApi::Parameter.new(
          name:         opts[:name],
          in:           opts[:in],
          description:  opts[:description],
          required:     opts[:required],
          deprecated:   opts[:deprecated],
          schema:       opts[:schema] || get_schema(opts[:value]),
          example:      opts[:value]
        )
      end

      def extract_unknown_parameters(example)
        parameters = []
        example.requests.each do |req|
          req[:request_query_parameters].each do |name, value|
            parameters.push(OpenApi::Parameter.new(
              name:     name,
              in:       :query,
              schema:   get_schema(value),
              example:  value
            ))
          end
          req[:request_headers].each do |name, value|
            parameters.push(OpenApi::Parameter.new(
              name:     name,
              in:       :header,
              schema:   get_schema(value),
              example:  value
            ))
          end
        end
        parameters
      end

      def extract_known_parameters(parameters)
        parameters.select { |parameter| %w(query path header cookie).include?(parameter[:in].to_s) }
          .map { |parameter| extract_parameter(parameter) }
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
