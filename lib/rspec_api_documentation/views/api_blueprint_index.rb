module RspecApiDocumentation
  module Views
    class ApiBlueprintIndex < MarkupIndex
      def initialize(index, configuration)
        super
        self.template_name = "rspec_api_documentation/api_blueprint_index"
      end

      def sections
        super.map do |section|
          routes = section[:examples].group_by { |e| "#{e.route_uri}#{e.route_optionals}#{e.route_name}" }.map do |route, examples|
            attrs  = fields(:attributes, examples)
            params = fields(:parameters, examples)

            methods = examples.group_by(&:http_method).map do |http_method, examples|
              {
                http_method: http_method,
                description: examples.first.respond_to?(:action_name) && examples.first.action_name,
                examples: examples
              }
            end

            {
              "has_attributes?".to_sym => attrs.size > 0,
              "has_parameters?".to_sym => params.size > 0,
              route: format_route(examples[0]),
              route_name: examples[0][:route_name],
              attributes: attrs,
              parameters: params,
              http_methods: methods
            }
          end

          section.merge({
            routes: routes
          })
        end
      end

      def examples
        @index.examples.map do |example|
          ApiBlueprintExample.new(example, @configuration)
        end
      end

      private

      # APIB follows the RFC 6570 to format URI templates.
      # According to it, simple string expansion (used to perform variable
      # expansion) should be represented by `{var}` and not by `/:var`
      # For example `/posts/:id` should become `/posts/{id}`
      # cf. https://github.com/apiaryio/api-blueprint/blob/format-1A/API%20Blueprint%20Specification.md#431-resource-section
      # cf. https://tools.ietf.org/html/rfc6570#section-3.2.6
      def format_route(example)
        route_uri = example[:route_uri].gsub(/:(.*?)([.\/?{]|$)/, '{\1}\2')
        "#{route_uri}#{example[:route_optionals]}"
      end

      # APIB has both `parameters` and `attributes`. This generates a hash
      # with all of its properties, like name, description, required.
      #   {
      #     required: true,
      #     example: "1",
      #     type: "string",
      #     name: "id",
      #     description: "The id",
      #     properties_description: "required, string"
      #   }
      def fields(property_name, examples)
        examples
          .map { |example| example.metadata[property_name] }
          .flatten
          .compact
          .uniq { |property| property[:name] }
          .map do |property|
            properties = []
            if property[:required] == true
              properties << 'required'
            else
              properties << 'optional'
            end
            properties << property[:type] if property[:type]
            if properties.count > 0
              property[:properties_description] = properties.join(", ")
            else
              property[:properties_description] = nil
            end

            property[:has_default?] = true if property[:default]
            property[:has_enum?] = true if property[:enum]

            property[:annotations] = property[:annotation].lines.map(&:chomp) if property[:annotation]

            property[:description] = nil if description_blank?(property)
            property
          end
      end

      # When no `description` was specified for a parameter, the DSL class
      # is making `description = "#{scope} #{name}"`, which is bad because it
      # assumes that all formats want this behavior. To avoid changing there
      # and breaking everything, I do my own check here and if description
      # equals the name, I assume it is blank.
      def description_blank?(property)
        !property[:description] ||
          property[:description].to_s.strip == property[:name].to_s.strip
      end
    end
  end
end
