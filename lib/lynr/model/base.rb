require 'json'

module Lynr; module Model;

  module Base

    def ==(o)
      if (!o.is_a?(::Hash) && self.respond_to?(:equality_fields, include_priv=true))
        equality_by_fields(o)
      else
        obj = (o.respond_to?(:view) && o.view) || o
        view == obj
      end
    end

    def to_json
      view.to_json
    end
    
    def view
      { }
    end

    private

    def equality_by_fields(o)
      result = equality_fields.reduce(true) do |result, property|
        result && o.respond_to?(property) && self.send(property) == o.send(property)
      end
      result
    end

  end

end; end;
