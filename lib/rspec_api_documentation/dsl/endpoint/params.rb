require 'rspec_api_documentation/dsl/endpoint/set_param'

module RspecApiDocumentation
  module DSL
    module Endpoint
      class Params
        attr_reader :example_group, :example

        def initialize(example_group, example:, extra_params:)
          @example_group = example_group
          @example = example
          @extra_params = extra_params
        end

        def call
          parameters = example.metadata.fetch(:parameters, {}).inject({}) do |hash, param|
            SetParam.new(self, hash: hash, param: param).call
          end
          parameters.deep_merge!(extra_params)
          parameters
        end

      private

        attr_reader :extra_params

      end
    end
  end
end
