module RspecApiDocumentation
  module Writers
    class SlateWriter < MarkdownWriter
      def markup_example_class
        RspecApiDocumentation::Views::SlateExample
      end
    end
  end
end
