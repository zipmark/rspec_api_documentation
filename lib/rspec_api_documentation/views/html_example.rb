module RspecApiDocumentation
  module Views
    class HtmlExample < MarkupExample
      EXTENSION = 'html'

      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/html_example"
      end

      def extension
        EXTENSION
      end

      def styles
        app_styles_url = RspecApiDocumentation.configuration.html_embedded_css_file
        gem_styles_url = File.join(File.dirname(__FILE__), "..", "assets", "stylesheets","rspec_api_documentation", "styles.css")
        return File.read(app_styles_url) rescue File.read(gem_styles_url)
      end
    end
  end
end
