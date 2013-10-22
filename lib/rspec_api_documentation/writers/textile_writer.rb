module RspecApiDocumentation
  module Writers
    class TextileWriter < GeneralMarkupWriter
      EXTENSION = 'textile'

      def markup_index_class
        RspecApiDocumentation::Views::TextileIndex
      end

      def markup_example_class
        RspecApiDocumentation::Views::TextileExample
      end

      def extension
        EXTENSION
      end
    end
  end
end
