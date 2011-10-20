$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

Bundler.require :default, :test

require 'active_support'
require 'rails/railtie'

module Rails
  def self.root
    Pathname.new("tmp")
  end
end

require 'rspec_api_documentation'
