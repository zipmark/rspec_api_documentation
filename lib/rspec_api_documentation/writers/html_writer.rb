module RspecApiDocumentation
  module Writers
    class HtmlWriter < GeneralMarkupWriter
      EXTENSION = 'html'

      def markup_index_class
        RspecApiDocumentation::Views::HtmlIndex
      end

      def markup_example_class
        RspecApiDocumentation::Views::HtmlExample
      end

      def extension
        EXTENSION
      end
    end
  end
end
