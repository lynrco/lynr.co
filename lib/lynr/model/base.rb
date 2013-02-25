module Lynr; module Model;

  module Base

    def ==(o)
      obj = o
      if (obj.respond_to?(:view))
        obj = o.view
      end
      view == obj
    end
    
    def view
      { }
    end

  end

end; end;
