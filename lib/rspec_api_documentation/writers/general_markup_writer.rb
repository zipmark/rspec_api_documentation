module RspecApiDocumentation
  module Writers
    # Base class for writers that write HTML
    class GeneralMarkupWriter < Writer
      INDEX_FILE_NAME = 'index'

      # Write out the generated documentation
      def write
        if render_options.fetch(:index, true)
          File.open(configuration.docs_dir.join(index_file_name + '.' + extension), "w+") do |f|
            f.write markup_index_class.new(index, configuration).render
          end
        end

        if render_options.fetch(:examples, true)
          index.examples.each do |example|
            markup_example = markup_example_class.new(example, configuration)
            FileUtils.mkdir_p(configuration.docs_dir.join(markup_example.dirname))

            File.open(configuration.docs_dir.join(markup_example.dirname, markup_example.filename), "w+") do |f|
              f.write markup_example.render
            end
          end
        end
      end

      def index_file_name
        INDEX_FILE_NAME
      end

      def extension
        raise 'Parent class. This method should not be called.'
      end

      private

      def render_options
        {
          index:    true,
          examples: true
        }
      end
    end
  end
end
