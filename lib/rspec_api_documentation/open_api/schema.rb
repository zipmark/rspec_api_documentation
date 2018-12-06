module RspecApiDocumentation
  module OpenApi
    class Schema < Node
      add_setting :title
      add_setting :multipleOf
      add_setting :maximum
      add_setting :exclusiveMaximum
      add_setting :minimum
      add_setting :exclusiveMinimum
      add_setting :maxLength
      add_setting :minLength
      add_setting :pattern
      add_setting :maxItems
      add_setting :minItems
      add_setting :uniqueItems
      add_setting :maxProperties
      add_setting :minProperties
      add_setting :required
      add_setting :enum
      add_setting :type
      add_setting :allOf, :schema => [Schema]
      add_setting :oneOf, :schema => [Schema]
      add_setting :anyOf, :schema => [Schema]
      add_setting :not, :schema => [Schema]
      add_setting :items
      add_setting :properties, :schema => { '' => Schema }
      add_setting :description
      add_setting :format
      add_setting :example
      add_setting :externalDocs, :schema => ExternalDocs
      add_setting :nullable
      add_setting :deprecated
      add_setting :discriminator
    end
  end
end
