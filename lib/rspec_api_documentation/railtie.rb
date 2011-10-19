module RspecApiDocumentation
  class Railtie < Rails::Railtie
    railtie_name :rspec_api_documentation

    rake_tasks do
      load "tasks/docs.rake"
    end
  end
end
