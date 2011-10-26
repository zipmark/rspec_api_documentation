module RspecApiDocumentation
  class Configuration
    def self.add_setting(name, opts = {})
      define_method("#{name}=") { |value| settings[name] = value }
      define_method("#{name}") do
        if settings.has_key?(name)
          settings[name]
        elsif opts[:default].respond_to?(:call)
          opts[:default].call(self)
        else
          opts[:default]
        end
      end
    end

    def self.default_example_template
      File.read(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'example_template.html'))
    end

    def self.default_index_template
      File.read(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'index_template.html'))
    end

    add_setting :docs_dir, :default => Rails.root.join("docs")
    add_setting :public_docs_dir, :default => Rails.root.join("public", "docs")
    add_setting :private_example_link, :default => "{{ link }}"
    add_setting :public_example_link, :default => "/docs/{{ link }}"
    add_setting :private_index_extension, :default => "html"
    add_setting :public_index_extension, :default => "html"
    add_setting :example_extension, :default => "html"
    add_setting :example_template, :default => default_example_template
    add_setting :index_template, :default => default_index_template

    def settings
      @settings ||= {}
    end
  end
end
