module RspecApiDocumentation
  module OpenApi
    class Header < Node
      add_setting :description
      add_setting :type, :required => true, :default => lambda { |header|
        Helper.extract_type(header.public_send('x-example-value'))
      }
      add_setting :format
      add_setting 'x-example-value'
    end
  end
end
