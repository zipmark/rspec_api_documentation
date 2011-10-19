module RspecApiDocumentation
  class ApiDocumentation
    class << self
      attr_accessor :docs_dir, :public_docs_dir, :private_example_link, :public_example_link,
        :private_index_extension, :public_index_extension

      def document_example(rspec_example, template)
        example = Example.new(rspec_example)
        FileUtils.mkdir_p(docs_dir.join(example.dirname))

        File.open(example.filepath(docs_dir), "w+") do |f|
          f.write(example.render(template))
        end
      end

      def index(rspec_example_group)
        example_group = ExampleGroup.new(rspec_example_group)
        File.open(docs_dir.join("index.#{private_index_extension}"), "a+") do |f|
          f.write("<h1>#{example_group.resource_name}</h1>")
          f.write("<ul>")
          example_group.documented_examples.each do |example|
            example = Example.new(example)
            link = Mustache.render(private_example_link, :link => "#{example.dirname}/#{example.filename}")
            f.write(%{<li><a href="#{link}">#{example.description}</a></li>})
          end
          f.write("</ul>")
        end

        return if example_group.public_examples.empty?

        File.open(public_docs_dir.join("index.#{public_index_extension}"), "a+") do |f|
          f.write("<h1>#{example_group.resource_name}</h1>")
          f.write("<ul>")
          example_group.public_examples.each do |example|
            example = Example.new(example)
            link = Mustache.render(public_example_link, :link => "#{example.dirname}/#{example.filename}")
            f.write(%{<li><a href="#{link}">#{example.description}</a></li>})
          end
          f.write("</ul>")
        end
      end

      def clear_docs
        puts "\tClearing out #{ApiDocumentation.docs_dir}"
        puts "\tClearing out #{ApiDocumentation.public_docs_dir}"

        FileUtils.rm_rf(docs_dir, :secure => true)
        FileUtils.mkdir_p(docs_dir)

        FileUtils.rm_rf(public_docs_dir, :secure => true)
        FileUtils.mkdir_p(public_docs_dir)
      end

      def docs_dir
        @docs_dir ||= Rails.root.join("docs")
      end

      def public_docs_dir
        @public_docs_dir ||= Rails.root.join("public", "docs")
      end

      def private_example_link
        @private_example_link ||= "{{ link }}"
      end

      def public_example_link
        @public_example_link ||= "/docs/{{ link }}"
      end

      def private_index_extension
        @private_index_extension ||= "html"
      end

      def public_index_extension
        @public_index_extension ||= "html"
      end
    end
  end
end
