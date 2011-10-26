module RspecApiDocumentation
  class Configuration
    attr_reader :format

    def initialize(format)
      @format = format
    end

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

    add_setting :docs_dir, :default => Rails.root.join("docs")
    add_setting :public_docs_dir, :default => Rails.root.join("public", "docs")
    add_setting :private_example_link, :default => "{{ link }}"
    add_setting :public_example_link, :default => "/docs/{{ link }}"
    add_setting :private_index_extension, :default => lambda { |config| config.format }
    add_setting :public_index_extension, :default => lambda { |config| config.format }
    add_setting :example_extension, :default => lambda { |config| config.format }
    add_setting :template_extension, :default => lambda { |config| config.format }
    add_setting :template_path, :default => File.expand_path("../../../templates", __FILE__)

    def settings
      @settings ||= {}
    end
  end
end
