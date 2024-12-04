module RspecApiDocumentation
  module Writers
    class DocusaurusWriter < GeneralMarkupWriter
      EXTENSION = 'md'

      def markup_index_class
        RspecApiDocumentation::Views::DocusaurusIndex
      end

      def markup_example_class
        RspecApiDocumentation::Views::DocusaurusExample
      end

      def extension
        EXTENSION
      end
    end
  end
end
