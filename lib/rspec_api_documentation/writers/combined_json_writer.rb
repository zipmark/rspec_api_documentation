require 'rspec_api_documentation/writers/json_writer'

module RspecApiDocumentation
  module Writers
    class CombinedJsonWriter < Writer
      def self.write(index, configuration)
        File.open(configuration.docs_dir.join("combined.json"), "w+") do |f|
          examples = []
          index.examples.each do |rspec_example|
            examples << Formatter.to_json(JsonExample.new(rspec_example, configuration))
          end

          f.write "["
          f.write examples.join(",")
          f.write "]"
        end
      end
    end
  end
end
