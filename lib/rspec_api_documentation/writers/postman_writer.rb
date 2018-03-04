require 'rspec_api_documentation/writers/formatter'

module RspecApiDocumentation
  module Writers
    class PostmanWriter < Writer
      attr_accessor :api_name
      delegate :docs_dir, :to => :configuration

      def initialize(index, configuration)
        super
        self.api_name = configuration.api_name.parameterize
      end

      def write
        File.open(docs_dir.join("#{api_name}.postman_collection.json"), "w+") do |file|
          file.write Formatter.to_json(Views::PostmanIndex.new(index, configuration))
        end
      end
    end
  end
end