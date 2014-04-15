module RspecApiDocumentation
  module Writers
    class MarkdownWriter < GeneralMarkupWriter
      EXTENSION = 'markdown'

      def markup_index_class
        RspecApiDocumentation::Views::MarkdownIndex
      end

      def markup_example_class
        RspecApiDocumentation::Views::MarkdownExample
      end

      def extension
        EXTENSION
      end
    end
  end
end
