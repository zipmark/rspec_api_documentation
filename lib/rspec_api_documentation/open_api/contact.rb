module RspecApiDocumentation
  module OpenApi
    class Contact < Node
      add_setting :name
      add_setting :url
      add_setting :email
    end
  end
end
