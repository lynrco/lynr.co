module Quicklist; module Model;

  # This is the primary object of the Application. Most of the data retrieval
  # will result in Vehicle objects.
  #
  # `Vehicle.new` takes a `Hash` containing specific data properties to set.
  #
  # * `:year`, `String` car year
  # * `:make`, `String` car make
  # * `:model`, `String` car model
  # * `:price`, an integer price in whole dollars (USD)
  # * `:condition`, an integer from 0-5, inclusive, representing condition of the
  #   vehicle. 0 indicates no rating
  # * `:mpg`, a `Quicklist::Model::Mpg` object containing information about highway
  #   and city mileage information.
  # * `:vin`, a `Quicklist::Model::Vin` object containing all the information
  #   that would be retrieved with a vin lookup. The object may or may not contain
  #   the actual vin number.
  # * `:images`, an `Array` of `Quicklist::Model::Image` objects.
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
      @mpg = data[:mpg] || nil # Should be an instance of Quicklist::Model::Mpg
      @vin = data[:vin] || nil # Should be an instance of Quicklist::Model::Vin
      @images = data[:images] || []
    end

    def set(data)
      Quicklist::Model::Vehicle.new(self.view.merge(data), @id)
    end

    # `Vehicle#view` is essentially the opposite of `Vehicle.inflate`. It
    # operates on the current Vehicle and deflates it down to a `Hash` of
    # properties.
    def view
      data = {
        year: @year,
        make: @make,
        model: @model,
        price: @price,
        condition: @condition,
        images: @images.map { |image| image.view }
      }
      data[:mpg] = @mpg.view if (@mpg)
      data[:vin] = @vin.view if (@vin)
      data
    end

    # `Vehicle.inflate` takes a database record and inflates the properties
    # into Quicklist objects to be used elsewhere
    def self.inflate(record)
      data = record.dup
      data[:vin] = Quicklist::Model::Vin.inflate(data[:vin])
      data[:mpg] = Quicklist::Model::Mpg.inflate(data[:mpg])
      Quicklist::Model::Vehicle.new(data, data[:_id])
    end

  end

end; end;
