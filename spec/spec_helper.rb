require 'active_support/dependencies/autoload'
require 'rspec_api_documentation'
require 'fakefs/spec_helpers'

module Rails
  def self.root
    Pathname.new("tmp")
  end
end
