module RspecApiDocumentation
  module Views
    class SlateExample < MarkdownExample
      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/slate_example"
      end

      def explanation_with_linebreaks
        explanation.gsub "\n", "<br>\n"
      end

      def write
        File.open(configuration.docs_dir.join("#{FILENAME}.#{extension}"), 'w+') do |file|

          sections.each do |section|
            file.write "# #{section[:resource_name]}\n\n"

            section[:examples].examples.sort_by!(&:description) unless configuration.keep_source_order

            section[:examples].examples.each do |example|
              markup_example = markup_example_class.new(example, configuration)
              file.write markup_example.render
            end
          end
        end
      end
    end
  end
end
