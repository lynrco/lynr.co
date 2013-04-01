require './lib/lynr/model/address'
require './lib/lynr/model/identity'
require './lib/lynr/model/image'

module Lynr; module Model;

  # `Dealership.new` takes a `Hash` containing data to set into the object.
  #
  # * `:name` of the dealership
  # * `:phone` number to reach the dealership
  # * `:identity` instance of `Lynr::Model::Identity containing credentials
  #   for logging in as this dealership
  # * `:address` on the street of the dealership, where to find the vehicles
  # * `:image` object pointing to the dealership logo or icon
  # * `:customer_id` from payment processor, how to identify payment details
  class Dealership

    attr_reader :id
    attr_reader :name, :phone, :identity, :address, :image, :customer_id

    def initialize(data, id=nil)
      @id = id
      @name = data['name'] || ""
      @phone = data['phone'] || ""
      @identity = data['identity']
      @address = data['address']
      @image = data['image']
      @customer_id = data['customer_id']
    end

    def view
      data = { 'name' => @name, 'phone' => @phone, 'customer_id' => @customer_id }
      data['identity'] = @identity.view if @identity
      data['address'] = @address.view if @address
      data['image'] = @image.view if @image
      data
    end

    def self.inflate(record)
      if (record)
        data = record.dup
        data['identity'] = Lynr::Model::Identity.inflate(record['identity'])
        data['address'] = Lynr::Model::Address.inflate(record['address'])
        data['image'] = Lynr::Model::Image.inflate(record['image'])
        Lynr::Model::Dealership.new(data, record['id'])
      else
        nil
      end
    end

  end

end; end;
