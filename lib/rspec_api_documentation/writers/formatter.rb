module RspecApiDocumentation
  module Writers
    module Formatter

      def self.to_json(object)
        JSON.pretty_generate(object.as_json) + "\n"
      end

    end
  end
end
