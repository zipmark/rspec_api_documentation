module RspecApiDocumentation
  module OpenApi
    module Helper
      module_function

      def extract_type(value)
        case value
        when Rack::Test::UploadedFile then :file
        when Array then :array
        when Hash then :object
        when TrueClass, FalseClass then :boolean
        when Integer then :integer
        when Float then :number
        else :string
        end
      end

      def extract_items(value, opts = {})
        result = {type: extract_type(value)}
        if result[:type] == :array
          result[:items] = extract_items(value[0], opts)
        else
          opts.each { |k, v| result[k] = v if v }
        end
        result
      end
    end
  end
end
