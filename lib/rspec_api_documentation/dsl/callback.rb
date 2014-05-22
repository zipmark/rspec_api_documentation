module RspecApiDocumentation::DSL
  # DSL Methods for testing server callbacks
  module Callback
    extend ActiveSupport::Concern

    delegate :request_method, :request_headers, :request_body, :to => :destination

    module ClassMethods
      def trigger_callback(&block)
        define_method(:do_callback) do
          require 'rack'
          stub_request(:any, callback_url).to_rack(destination)
          instance_eval &block
        end
      end
    end

    def destination
      @destination ||= RspecApiDocumentation::TestServer.new(RSpec.current_example)
    end

    def callback_url
      raise "You must define callback_url"
    end
  end
end
