module RspecApiDocumentation
  module DSL
    extend ActiveSupport::Concern

    module ClassMethods
      def get(*args, &block)
        options = if args.last.is_a?(Hash) then args.pop else {} end
        options[:method] = :get
        options[:path] = args.first
        args.push(options)
        context(*args, &block)
      end

      def post(*args, &block)
        options = if args.last.is_a?(Hash) then args.pop else {} end
        options[:method] = :post
        options[:path] = args.first
        args.push(options)
        context(*args, &block)
      end

      def put(*args, &block)
        options = if args.last.is_a?(Hash) then args.pop else {} end
        options[:method] = :put
        options[:path] = args.first
        args.push(options)
        context(*args, &block)
      end

      def delete(*args, &block)
        options = if args.last.is_a?(Hash) then args.pop else {} end
        options[:method] = :delete
        options[:path] = args.first
        args.push(options)
        context(*args, &block)
      end

      def parameter(name, description)
        metadata[:parameters] ||= {}
        metadata[:parameters][name] = {:description => description}
      end

      def required_parameters(*names)
        names.each do |name|
          metadata[:parameters][name][:required] = true
        end
      end
    end

    module InstanceMethods
      def client
        @client ||= TestClient.new(self)
      end

      def do_request
        client.send(method, path)
      end

      def params
        example.metadata[:parameters].inject({}) do |h, (k, v)|
          if respond_to?(k)
            h[k] = send(k)
          end
          h
        end
      end

      def method
        example.metadata[:method]
      end

      def path
        example.metadata[:path]
      end
    end
  end
end

def self.resource(*args, &block)
  options = if args.last.is_a?(Hash) then args.pop else {} end
  options[:resource_name] = args.first
  args.push(options)
  describe(*args, &block)
end

RSpec.configuration.include RspecApiDocumentation::DSL
