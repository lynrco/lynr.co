require 'bson'

module BSON

  # # `BSON::DBRef`
  #
  # This monkey-patches `DBRef` to add an equals method.
  #
  class DBRef

    # ## `BSON::DBRef#==(ref)`
    #
    # Evaluate the equality of two `DBRef` instances by check namespace and
    # object id equality.
    #
    def ==(ref)
      result = ref.is_a? BSON::DBRef
      result = result && self.namespace == ref.namespace
      result = result && self.object_id == ref.object_id
      result
    end

  end

end
