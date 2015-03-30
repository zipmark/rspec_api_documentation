require "bundler/gem_tasks"

require "cucumber/rake/task"
Cucumber::Rake::Task.new(:cucumber)

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

task :default => [:spec, :cucumber]

require 'rdoc/task'
Rake::RDocTask.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
end
