require 'rspec_api_documentation/writers/formatter'

module RspecApiDocumentation
  module Writers
    class AppendJsonWriter < JsonWriter
      def write
        index_file = docs_dir.join("index.json")
        if File.exists?(index_file) && (output = File.read(index_file)).length >= 2
          existing_index_hash = JSON.parse(output)
        end
        File.open(index_file, "w+") do |f|
          f.write Formatter.to_json(AppendJsonIndex.new(index, configuration, existing_index_hash))
        end
        write_examples
      end

      def self.clear_docs(docs_dir)
        nil #noop
      end
    end

    class AppendJsonIndex < JsonIndex
      def initialize(index, configuration, existing_index_hash = nil)
        @index = index
        @configuration = configuration
        @existing_index_hash = clean_index_hash(existing_index_hash)
      end

      def as_json(opts = nil)
        sections.inject(@existing_index_hash) do |h, section|
          h[:resources].push(section_hash(section))
          h
        end
      end

      def clean_index_hash(existing_index_hash)
        unless existing_index_hash.is_a?(Hash) && existing_index_hash["resources"].is_a?(Array) #check format
          existing_index_hash = {:resources => []}
        end
        existing_index_hash = existing_index_hash.deep_symbolize_keys
        existing_index_hash[:resources].map!(&:deep_symbolize_keys).reject! do |resource|
          resource_names = sections.map{|s| s[:resource_name]}
          resource_names.include? resource[:name]
        end
        existing_index_hash
      end
    end
  end
end
