module RspecApiDocumentation
  module Writers
    module Formatter

      def self.to_json(object)
        JSON.pretty_generate(object.as_json)
      end

    end
  end
end