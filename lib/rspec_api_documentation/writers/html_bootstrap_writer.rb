module RspecApiDocumentation
  module Writers
    class HtmlBootstrapWriter < HtmlWriter
      attr_accessor :index, :configuration

      EXTENSION = 'html'

      def markup_index_class
        RspecApiDocumentation::Views::HtmlBootstrapIndex
      end

      def markup_example_class
        RspecApiDocumentation::Views::HtmlBootstrapExample
      end

      def extension
        EXTENSION
      end
    end
  end
end
