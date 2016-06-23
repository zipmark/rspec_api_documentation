module RspecApiDocumentation
  module Writers

    class SlateWriter < MarkdownWriter
      EXTENSION = 'html.md'
      FILENAME = 'index'

      def self.clear_docs(docs_dir)
        FileUtils.mkdir_p(docs_dir)
        FileUtils.rm Dir[File.join docs_dir, "#{FILENAME}.*"]
      end

      def markup_index_class
        RspecApiDocumentation::Views::SlateIndex
      end

      def markup_example_class
        RspecApiDocumentation::Views::SlateExample
      end

      def write
        File.open(configuration.docs_dir.join("#{FILENAME}.#{extension}"), 'w+') do |file|

          file.write %Q{---\n}
          file.write %Q{title: "#{configuration.api_name}"\n}
          file.write %Q{language_tabs:\n}
          file.write %Q{  - json: JSON\n}
          file.write %Q{---\n\n}

          IndexHelper.sections(index.examples, @configuration).each do |section|

            file.write "# #{section[:resource_name]}\n\n"
            section[:examples].sort_by!(&:description) unless configuration.keep_source_order

            section[:examples].each do |example|
              markup_example = markup_example_class.new(example, configuration)
              file.write markup_example.render
            end

          end

        end
      end

      def extension
        EXTENSION
      end
    end
  end
end
