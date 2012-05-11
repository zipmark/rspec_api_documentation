require 'rspec/core/rake_task'

unless Rails.env.production?
  desc 'Generate API request documentation from API specs'
  RSpec::Core::RakeTask.new('docs:generate') do |t|
    t.pattern = 'spec/acceptance/**/*_spec.rb'
    t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter"]
  end
end
