require 'rspec/core/rake_task'

desc 'Generate API request documentation from API specs'
RSpec::Core::RakeTask.new('docs:generate') do |t|
  t.pattern = 'spec/acceptance/**/*_spec.rb'
  t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter"]
end

desc 'Generate API request documentation from API specs (ordered)'
RSpec::Core::RakeTask.new('docs:generate:ordered') do |t|
  t.pattern = 'spec/acceptance/**/*_spec.rb'
  t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter", "--order defined"]
end

desc "Generate API request documentation from API specs, and skip tests that don't generate any docs"
RSpec::Core::RakeTask.new('docs:generate:skip_undocumenting') do |t|
  t.pattern = 'spec/acceptance/**/*_spec.rb'
  t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter", "--tag ~@document:false"]
end
