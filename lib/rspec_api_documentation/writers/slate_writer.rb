module RspecApiDocumentation
  module Writers
    FILENAME = '_generated_examples'

    class SlateWriter < MarkdownWriter
      def self.clear_docs(docs_dir)
        FileUtils.mkdir_p(docs_dir)
        FileUtils.rm Dir[File.join docs_dir, "#{FILENAME}.*"]
      end

      def markup_example_class
        RspecApiDocumentation::Views::SlateExample
      end

      def write
        File.open(configuration.docs_dir.join("#{FILENAME}.#{extension}"), 'w+') do |file|
          file.write "# #{configuration.api_name}\n\n"
          index.examples.sort_by!(&:description) unless configuration.keep_source_order

          index.examples.each do |example|
            markup_example = markup_example_class.new(example, configuration)
            file.write markup_example.render
          end
        end
      end
    end
  end
end
