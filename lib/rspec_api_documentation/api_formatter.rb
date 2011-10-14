require 'rspec/core/formatters/base_formatter'

module RspecApiDocumentation
  class APIFormatter < RSpec::Core::Formatters::BaseFormatter
    def initialize(output)
      super(output)

      puts "Generating API docs"
    end

    def clear_docs
      unless @cleared
        ApiDocumentation.clear_docs
      end

      @cleared = true
    end

    def example_group_started(example_group)
      clear_docs

      puts "\t * #{example_group.resource_name}"
    end

    def example_group_finished(example_group)
      ApiDocumentation.index(example_group)
      example_group.symlink_public_examples
    end

    def example_passed(example)
      return unless example.should_document?

      puts "\t\t * #{example.description}"

      ApiDocumentation.document_example(example, template)
    end

    def example_failed(example)
      application_callers = example.metadata[:caller].select { |file_line| file_line =~ /^#{Rails.root}/ }
      puts "\t*** EXAMPLE FAILED ***. #{example.resource_name}. Tests should pass before we generate docs."
      puts "\t\tDetails: #{example.metadata[:execution_result][:exception]}"
      print "\t\tApplication Backtrace:\n\t\t"
      puts application_callers.join("\n\t\t")
    end

    private
    def template
      File.read(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'example_template.html'))
    end
  end

  module DocumentResource
    def resource_name
      metadata[:resource_name]
    end
  end

  class ApiDocumentation
    class << self
      attr_accessor :docs_dir, :public_docs_dir, :private_example_link, :public_example_link,
        :private_index_extension, :public_index_extension

      def document_example(example, template)
        FileUtils.mkdir_p(docs_dir.join(example.dirname))

        File.open(example.filepath(docs_dir), "w+") do |f|
          f.write(example.render(template))
        end
      end

      def index(example_group)
        File.open(docs_dir.join("index.#{private_index_extension}"), "a+") do |f|
          f.write("<h1>#{example_group.resource_name}</h1>")
          f.write("<ul>")
          example_group.documented_examples.each do |example|
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

class RSpec::Core::ExampleGroup
  extend RspecApiDocumentation::DocumentResource

  def self.dirname
    resource_name.downcase.gsub(/\s+/, '_')
  end

  def self.documented_examples
    examples.select { |e| e.should_document? }
  end

  def self.public_examples
    documented_examples.select { |e| e.public? }
  end

  def self.document_example(text)
    metadata[:documentation] = text
  end

  def self.symlink_public_examples
    public_dir = RspecApiDocumentation::ApiDocumentation.public_docs_dir.join(dirname)
    private_dir = RspecApiDocumentation::ApiDocumentation.docs_dir.join(dirname)

    unless public_examples.empty?
      FileUtils.mkdir_p public_dir
    end

    public_examples.each do |example|
      FileUtils.ln_s(private_dir.join(example.filename), public_dir.join(example.filename))
    end
  end
end

class RSpec::Core::Example
  include RspecApiDocumentation::DocumentResource

  def filename
    description.downcase.gsub(/\s+/, '_').gsub(/[^a-z_]/, '') + ".html"
  end

  def dirname
    example_group.dirname
  end

  def filepath(base_dir)
    base_dir.join(dirname, filename)
  end

  def should_document?
    !pending? && metadata[:resource_name] && metadata[:document]
  end

  def render(template)
    Mustache.render(template, template_content)
  end

  def template_content
    example_group.metadata.merge :action => metadata
  end

  def public?
    metadata[:public]
  end
end

