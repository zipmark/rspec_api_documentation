require 'rspec/core/rake_task'

desc 'Generate API request documentation from API specs'
RSpec::Core::RakeTask.new('docs:generate', [:spec_folder]) do |t, args|
  spec_folder = args[:spec_folder] || "acceptance"
  t.pattern = "spec/#{spec_folder}/**/*_spec.rb"
  t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter"]
end

desc 'Generate API request documentation from API specs (ordered)'
RSpec::Core::RakeTask.new('docs:generate:ordered', [:spec_folder]) do |t, args|
  spec_folder = args[:spec_folder] || "acceptance"
  t.pattern = "spec/#{spec_folder}/**/*_spec.rb"
  t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter", "--order defined"]
end
