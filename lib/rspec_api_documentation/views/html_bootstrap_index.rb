module RspecApiDocumentation
  module Views
    class HtmlBootstrapIndex < HtmlIndex

      attr_accessor :bootstrap_css_url

      def initialize(index, configuration)
        super
        self.template_name = "rspec_api_documentation/html_bootstrap_index"
        @bootstrap_css_url = configuration.bootstrap_css_url
      end
    end
  end
end
