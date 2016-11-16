module RspecApiDocumentation
  module Views
    class ApiBlueprintIndex < MarkupIndex
      def initialize(index, configuration)
        super
        self.template_name = "rspec_api_documentation/api_blueprint_index"
      end

      def sections
        super.map do |section|
          routes = section[:examples].group_by(&:route_uri).map do |route_uri, examples|
            attrs = examples.map { |example| example.metadata[:attributes] }.flatten.compact.uniq { |attr| attr[:name] }
            params = examples.map { |example| example.metadata[:parameters] }.flatten.compact.uniq { |param| param[:name] }

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
              route_uri: route_uri,
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
    end
  end
end
