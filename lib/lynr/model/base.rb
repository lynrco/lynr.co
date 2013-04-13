module Lynr; module Model;

  module Base

    def ==(o)
      obj = (o.respond_to?(:view) && o.view) || o
      view == obj
    end
    
    def view
      { }
    end

  end

end; end;
