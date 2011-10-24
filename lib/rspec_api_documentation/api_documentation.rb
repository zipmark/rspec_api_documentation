module RspecApiDocumentation
  class ApiDocumentation
    attr_reader :configuration, :examples, :private_index, :public_index

    delegate :docs_dir, :public_docs_dir, :example_template, :to => :configuration

    def initialize(configuration)
      @configuration = configuration
      @examples = []
      @private_index = Index.new
      @public_index = Index.new
    end

    def clear_docs
      [docs_dir, public_docs_dir].each do |dir|
        if File.exists?(dir)
          FileUtils.rm_rf(dir, :secure => true)
        end
        FileUtils.mkdir_p(dir)
      end
    end

    def document_example(example)
      wrapped_example = Example.new(example)
      if wrapped_example.should_document?
        examples << wrapped_example
        private_index.add_example(example)
        public_index.add_example(example) if wrapped_example.public?
      end
    end

    def write_examples
      examples.each do |example|
        write_example(example)
      end
    end

    def write_example(wrapped_example)
      dir = docs_dir.join(wrapped_example.dirname)
      file = dir.join("#{wrapped_example.filename}.#{configuration.example_extension}")
      rendered_output = Mustache.render(example_template, wrapped_example.metadata)

      FileUtils.mkdir_p(dir)
      File.open(file, 'w') { |f| f.write rendered_output }
    end

    #class << self
    #  delegate :configuration, :to => :RspecApiDocumentation

    #  def document_example(rspec_example, template)
    #    example = Example.new(rspec_example)
    #    FileUtils.mkdir_p(configuration.docs_dir.join(example.dirname))

    #    File.open(example.filepath(configuration.docs_dir), "w+") do |f|
    #      f.write(example.render(template))
    #    end
    #  end

    #  def index(rspec_example_group)
    #    example_group = ExampleGroup.new(rspec_example_group)
    #    File.open(configuration.docs_dir.join("index.#{configuration.private_index_extension}"), "a+") do |f|
    #      f.write("<h1>#{example_group.resource_name}</h1>")
    #      f.write("<ul>")
    #      example_group.documented_examples.each do |example|
    #        example = Example.new(example)
    #        link = Mustache.render(configuration.private_example_link, :link => "#{example.dirname}/#{example.filename}")
    #        f.write(%{<li><a href="#{link}">#{example.description}</a></li>})
    #      end
    #      f.write("</ul>")
    #    end

    #    return if example_group.public_examples.empty?

    #    File.open(configuration.public_docs_dir.join("index.#{configuration.public_index_extension}"), "a+") do |f|
    #      f.write("<h1>#{example_group.resource_name}</h1>")
    #      f.write("<ul>")
    #      example_group.public_examples.each do |example|
    #        example = Example.new(example)
    #        link = Mustache.render(configuration.public_example_link, :link => "#{example.dirname}/#{example.filename}")
    #        f.write(%{<li><a href="#{link}">#{example.description}</a></li>})
    #      end
    #      f.write("</ul>")
    #    end
    #  end

    #  def clear_docs
    #    puts "\tClearing out #{configuration.docs_dir}"
    #    puts "\tClearing out #{configuration.public_docs_dir}"

    #    FileUtils.rm_rf(configuration.docs_dir, :secure => true)
    #    FileUtils.mkdir_p(configuration.docs_dir)

    #    FileUtils.rm_rf(configuration.public_docs_dir, :secure => true)
    #    FileUtils.mkdir_p(configuration.public_docs_dir)
    #  end
    #end
  end
end
