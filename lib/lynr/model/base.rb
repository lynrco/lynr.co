require 'json'

module Lynr; module Model;

  # # `Lynr::Model::Base`
  #
  # Module to be included by `Lynr::Model` objects which defines how equality
  # works for modle objects. Classes including the `Model::Base` module should
  # define a `#view` method to provide a `Hash` representation of itself. If the
  # including class will `respond_to?(:equality_fields)` then `#==` will be defined
  # to compare values from `#equality_fields` otherwise `#==` is defined to compare
  # two instances based on their `#view`s.
  #
  module Base

    # ## `Base#==(o)`
    #
    # Define equality based on `#equality_fields` using `#equality_by_fields` method
    # otherwise compare this instances `#view` to the `#view` of `o` or to `o` itself
    # if `o` doesn't respond to a `:view` message.
    #
    def ==(o)
      if (!o.is_a?(::Hash) && self.respond_to?(:equality_fields, include_priv=true))
        equality_by_fields(o)
      else
        obj = (o.respond_to?(:view) && o.view) || o
        view == obj
      end
    end

    # ## `Base#to_json`
    #
    # Create a JSON String representation of this instance based on `#view`.
    #
    def to_json
      view.to_json
    end

    # ## `Base#view`
    #
    # Default view is an empty `Hash`. This method should be overridden by the
    # including class.
    #
    def view
      { }
    end

    private

    # ## `Base#equality_by_fields(o)`
    #
    # *Private* Compare values from this instance to values from `o` when both
    # `self` and `o` are sent a message based on `#equality_fields`.
    #
    def equality_by_fields(o)
      result = equality_fields.reduce(true) do |result, property|
        result && o.respond_to?(property) && self.send(property) == o.send(property)
      end
      result
    end

  end

end; end;
