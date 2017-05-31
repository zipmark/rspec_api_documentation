module RspecApiDocumentation
  module DSL
    module Endpoint
      class SetParam
        def initialize(parent, hash, param)
          @parent = parent
          @hash = hash
          @param = param
        end

        def call
          return hash if path_params.include?(path_name)
          return hash unless method_name

          hash.deep_merge build_param_hash(key_scope || [key])
        end

        def value
          example_group.send(method_name) if method_name
        end

      private

        attr_reader :parent, :hash, :param
        delegate :example_group, :example, to: :parent

        def key
          @key ||= param[:name]
        end

        def key_scope
          @key_scope ||= param[:scope] && Array(param[:scope]).dup.push(key)
        end

        def scoped_key
          @scoped_key ||= key_scope && key_scope.join('_')
        end

        def custom_method_name
          param[:method]
        end

        def set_value
          param[:value]
        end

        def path_name
          scoped_key || key
        end

        def path_params
          example.metadata[:route].scan(/:(\w+)/).flatten
        end

        def method_name
          if custom_method_name
            custom_method_name if example_group.respond_to?(custom_method_name)
          elsif scoped_key && example_group.respond_to?(scoped_key)
            scoped_key
          elsif key && example_group.respond_to?(key)
            key
          elsif key && set_value
            key
          end
        end

        def build_param_hash(keys)
          value = param[:value] if param.has_key?(:value)
          value ||= keys[1] ? build_param_hash(keys[1..-1]) : example_group.send(method_name)
          { keys[0].to_s => value }
        end
      end
    end
  end
end
