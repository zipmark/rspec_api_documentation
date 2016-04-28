module RspecApiDocumentation
  module Views
    class SlateExample < MarkdownExample
      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/slate_example"
      end

      def curl_with_linebreaks
        requests.map {|request| request[:curl].lines }.flatten.map do |line|
          line.rstrip.gsub("\t", '  ').gsub(' ', '&nbsp;').gsub('\\', '&#92;')
        end.join "<br>"
      end

      def explanation_with_linebreaks
        explanation.gsub "\n", "<br>\n"
      end
    end
  end
end
