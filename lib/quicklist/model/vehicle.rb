module Quicklist; module Model;

  class Vehicle

    attr_reader :id
    attr_reader :year, :make, :model, :price, :condition, :mpg, :vin, :images

    def initialize(data, id=nil)
      @id = id
      @year = data[:year] || ""
      @make = data[:make] || ""
      @model = data[:model] || ""
      @price = data[:price] || nil
      @condition = data[:condition] || 0
      @mpg = data[:mpg] || nil
      @vin = data[:vin] || nil
      @images = data[:images] || []
    end

    def set(data)
      Quicklist::Model::Vehicle.new(self.view.merge(data), @id)
    end

    def view
      data = {
        year: @year,
        make: @make,
        model: @model,
        price: @price,
        condition: @condition,
        images: @images.map { |image| image.view }
      }
      if (@mpg)
        data[:mpg] = @mpg.view
      end
      if (@vin)
        data[:vin] = @vin.view
      end
      data
    end

  end

end; end;
