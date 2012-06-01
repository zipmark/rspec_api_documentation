module RspecApiDocumentation
  class CombinedTextWriter
    def self.write(index, configuration)
      index.examples.each do |example|
        resource_name = example.resource_name.downcase.gsub(/\s+/, '_')
        FileUtils.mkdir_p(configuration.docs_dir.join(resource_name))
        File.open(configuration.docs_dir.join(resource_name, "index.txt"), "a+") do |f|
          f.puts example.description
          f.puts "-" * example.description.length
          f.puts

          f.puts "Parameters:"
          example.metadata[:parameters].each do |parameter|
            f.puts "  * #{parameter[:name]} - #{parameter[:description]}"
          end
          f.puts

          example.metadata[:requests].each do |request|
            f.puts "Request:"
            f.puts "  #{request[:request_method]} #{request[:request_path]}"
            f.puts
            f.puts format_hash(request[:request_body] || request[:request_query_parameters])
            f.puts
            f.puts "Response:"
            f.puts "  Status: #{request[:response_status]} #{request[:response_status_text]}"
            f.puts format_hash(request[:response_headers], ": ")
            f.puts
            f.puts request[:response_body].split("\n").map { |line| "  #{line}" }.join("\n")
          end

          unless example == index.examples.last
            f.puts
            f.puts
          end
        end
      end
    end

    def self.format_hash(hash, separator="=")
      hash.inject("") do |out, (k, v)|
        out << "  #{k}#{separator}#{v}\n"
      end
    end
  end
end
