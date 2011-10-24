module RspecApiDocumentation
  class Configuration
    def self.add_setting(name, opts = {})
      define_method("#{name}=") { |value| settings[name] = value }
      define_method("#{name}") { settings.has_key?(name) ? settings[name] : opts[:default] }
    end

    add_setting :docs_dir, :default => Rails.root.join("docs")
    add_setting :public_docs_dir, :default => Rails.root.join("public", "docs")
    add_setting :private_example_link, :default => "{{ link }}"
    add_setting :public_example_link, :default => "/docs/{{ link }}"
    add_setting :private_index_extension, :default => "html"
    add_setting :public_index_extension, :default => "html"

    def settings
      @settings ||= {}
    end

    def clear_docs
      [docs_dir, public_docs_dir].each do |dir|
        if File.exists?(dir)
          FileUtils.rm_rf(dir, :secure => true)
        end
        FileUtils.mkdir_p(dir)
      end
    end
  end
end
