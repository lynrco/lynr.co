module Lynr; module Model;

  module BaseDated

    def ==(vehicle)
      return false unless vehicle.is_a? self.class
      my_view = self.view.delete_if { |k,v| ['updated_at', 'created_at'].include?(k) }
      ov_view = vehicle.view.delete_if { |k,v| ['updated_at', 'created_at'].include?(k) }
      my_view == ov_view
    end

  end

end; end;
