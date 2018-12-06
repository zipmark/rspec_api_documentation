module RspecApiDocumentation
  module OpenApi
    class Response < Node
      add_setting :description, :required => true, :default => 'Successful operation'
      add_setting :headers, :schema => { '' => Header }
      add_setting :content, :schema => { '' => Media }
      # add_setting :links
    end
  end
end
