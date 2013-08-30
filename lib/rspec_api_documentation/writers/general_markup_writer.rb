module RspecApiDocumentation
  module Writers
    class GeneralMarkupWriter
      attr_accessor :index, :configuration

      INDEX_FILE_NAME = 'index'
      
      def initialize(index, configuration)
        self.index = index
        self.configuration = configuration
      end

      def self.write(index, configuration)
        writer = new(index, configuration)
        writer.write
      end
      
      def write
        File.open(configuration.docs_dir.join(index_file_name + '.' + extension), "w+") do |f|
          f.write markup_index_class.new(index, configuration).render
        end

        index.examples.each do |example|
          markup_example = markup_example_class.new(example, configuration)
          FileUtils.mkdir_p(configuration.docs_dir.join(markup_example.dirname))

          File.open(configuration.docs_dir.join(markup_example.dirname, markup_example.filename), "w+") do |f|
            f.write markup_example.render
          end
        end
      end

      def index_file_name
        INDEX_FILE_NAME
      end

      def extension
        raise 'Parent class. This method should not be called.'
      end
    end
  end
end
