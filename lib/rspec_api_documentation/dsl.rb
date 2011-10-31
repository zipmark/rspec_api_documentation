module RspecApiDocumentation
  module DSL
    extend ActiveSupport::Concern

    module ClassMethods
      def self.define_action(method)
        define_method method do |*args, &block|
          options = if args.last.is_a?(Hash) then args.pop else {} end
          options[:method] = method
          options[:path] = args.first
          args.push(options)
          context(*args, &block)
        end
      end

      define_action :get
      define_action :post
      define_action :put
      define_action :delete

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
          h[k] = send(k) if respond_to?(k)
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
