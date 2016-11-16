module RspecApiDocumentation
  module Writers
    class ApiBlueprintWriter < GeneralMarkupWriter
      EXTENSION = 'apib'

      def markup_index_class
        RspecApiDocumentation::Views::ApiBlueprintIndex
      end

      def markup_example_class
        RspecApiDocumentation::Views::ApiBlueprintExample
      end

      def extension
        EXTENSION
      end

      private

      # API Blueprint is a spec, not navigable like HTML, therefore we generate
      # only one file with all resources.
      def render_options
        super.merge({
          examples: false
        })
      end
    end
  end
end
