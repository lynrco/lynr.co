require 'bson'

module BSON

  class DBRef

    def ==(ref)
      result = ref.is_a? BSON::DBRef
      result = result && self.namespace == ref.namespace
      result = result && self.object_id == ref.object_id
      result
    end

  end

end
