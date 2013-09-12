module RspecApiDocumentation
  module Views
    class HtmlBootstrapExample < HtmlExample

      attr_accessor :bootstrap_css_url

      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/html_bootstrap_example"
        @bootstrap_css_url = configuration.boostrap_css_url
      end

      def requests
        super.map do |hash|
          hash[:response_body_pretty] = JSON.pretty_generate(JSON.parse(hash[:response_body]))
          hash
        end
      end

    end
  end
end
