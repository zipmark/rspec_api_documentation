module RspecApiDocumentation
  module OpenApi
    class License < Node
      add_setting :name, :default => 'Apache 2.0', :required => true
      add_setting :url, :default => 'http://www.apache.org/licenses/LICENSE-2.0.html'
    end
  end
end
