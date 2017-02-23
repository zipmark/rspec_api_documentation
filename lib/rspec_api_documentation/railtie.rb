module RspecApiDocumentation
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.join(File.dirname(__FILE__), '../tasks/docs.rake')
    end
  end
end
