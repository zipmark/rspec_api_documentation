require 'active_support/concern'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/delegation.rb'
require 'active_support/json'
require 'mustache'
require 'rspec_api_documentation'
require 'fakefs/spec_helpers'

module Rails
  def self.root
    Pathname.new("tmp")
  end
end
