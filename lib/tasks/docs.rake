require 'rspec/core/rake_task'

if Rails.env.test? || Rails.env.development?
  desc 'Generate API request documentation from API specs'
  RSpec::Core::RakeTask.new('docs:generate') do |t|
    t.pattern = 'spec/acceptance/*_spec.rb'
    t.rspec_opts = ["--format APIFormatter"]
  end
end
