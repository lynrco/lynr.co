module Lynr; module Model;

  module BaseDated

    def ==(o)
      return false unless o.is_a? self.class
      my_view = self.view.delete_if { |k,v| ['updated_at', 'created_at'].include?(k) }
      o_view = o.view.delete_if { |k,v| ['updated_at', 'created_at'].include?(k) }
      my_view == o_view
    end

  end

end; end;
