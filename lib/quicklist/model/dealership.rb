module Quicklist; module Model;

  # `Dealership.new` takes a `Hash` containing data to set into the object.
  #
  # * `:name` of the dealership
  # * `:phone` number to reach the dealership
  # * `:identity` instance of `Quicklist::Model::Identity containing credentials
  #   for logging in as this dealership
  # * `:address` on the street of the dealership, where to find the vehicles
  # * `:image` object pointing to the dealership logo or icon
  class Dealership

    attr_reader :id
    attr_reader :name, :phone, :identity, :address, :image

    def initialize(data, id=nil)
      @id = id
      @name = data[:name] || ""
      @phone = data[:phone] || ""
      @identity = data[:identity]
      @address = data[:address]
      @image = data[:image]
    end

    def view
      data = { name: @name, phone: @phone }
      data[:identity] = @identity.view if @identity
      data[:address] = @address.view if @address
      data[:image] = @image.view if @image
      data
    end

  end

end; end;
