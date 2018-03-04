module RspecApiDocumentation
  module Views
    class PostmanIndex
      POSTMAN_SCHEMA = 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'.freeze

      def initialize(index, configuration)
        @index = index
        @configuration = configuration
      end

      def sections
        Writers::IndexHelper.sections(examples, @configuration)
      end

      def examples
        @index.examples.map do |example|
          Views::PostmanRequestExample.new(example)
        end
      end

      def as_json(opts = nil)
        collections = { :info => { :name => @configuration.api_name,
                                   :description => @configuration.api_explanation,
                                   :schema => POSTMAN_SCHEMA },
                        :item => []
        }

        sections.each do |section|
          folder = { :name => section[:resource_name],
                     :description => section[:resource_explanation],
                     :item => section[:examples].map do |example|
                       example.as_json(opts)
                     end
          }
          collections[:item] << folder
        end

        collections
      end
    end
  end
end