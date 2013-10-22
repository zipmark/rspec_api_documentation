module RspecApiDocumentation
  module Writers
    class Writer
      attr_accessor :index, :configuration

      def initialize(index, configuration)
        self.index = index
        self.configuration = configuration
      end

      def self.write(index, configuration)
        writer = new(index, configuration)
        writer.write
      end

      def self.clear_docs(docs_dir)
        if File.exists?(docs_dir)
          FileUtils.rm_rf(docs_dir, :secure => true)
        end
        FileUtils.mkdir_p(docs_dir)
      end
    end
  end
end

