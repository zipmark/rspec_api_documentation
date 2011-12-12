require 'active_support/all'
require 'rspec_api_documentation'
require 'fakefs/spec_helpers'

module Rails
  def self.root
    Pathname.new("tmp")
  end
end
