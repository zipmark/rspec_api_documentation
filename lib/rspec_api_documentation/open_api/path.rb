module RspecApiDocumentation
  module OpenApi
    class Path < Node
      add_setting :get, :schema => Operation
      add_setting :put, :schema => Operation
      add_setting :post, :schema => Operation
      add_setting :delete, :schema => Operation
      add_setting :options, :schema => Operation
      add_setting :head, :schema => Operation
      add_setting :patch, :schema => Operation
    end
  end
end
