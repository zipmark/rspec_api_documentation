module RspecApiDocumentation
  module OpenApi
    class Responses < Node
      CHILD_CLASS = Response

      add_setting :default, :default => lambda { |responses| responses.existing_settings.size > 1 ? nil : Response.new }
    end
  end
end
