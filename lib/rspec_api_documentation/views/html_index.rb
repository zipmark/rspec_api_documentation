module RspecApiDocumentation
  module Views
    class HtmlIndex < MarkupIndex
      def initialize(index, configuration)
        super
        self.template_name = "rspec_api_documentation/html_index"
      end

      def styles
        app_styles_url = File.join(Dir.pwd, "app", "assets", "stylesheets","rspec_api_documentation", "styles.css")
        gem_styles_url = File.join(File.dirname(__FILE__), "..", "assets", "stylesheets","rspec_api_documentation", "styles.css")
        return File.read(app_styles_url) rescue File.read(gem_styles_url)
      end

      def examples
        @index.examples.map { |example| HtmlExample.new(example, @configuration) }
      end
    end
  end
end
