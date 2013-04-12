require 'lynr/model/address'
require 'lynr/model/base'
require 'lynr/model/identity'
require 'lynr/model/image'

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

    include Lynr::Model::Base

    attr_reader :id
    attr_reader :name, :phone, :identity, :address, :postcode, :image, :customer_id

    def initialize(data={}, id=nil)
      @id = id
      @name = data['name'] || ""
      @phone = data['phone'] || ""
      @identity = data['identity']
      @address = data['address'] || ""
      @postcode = data['postcode'] || ""
      @image = data['image']
      @customer_id = data['customer_id']
    end

    def set(data={})
      Lynr::Model::Dealership.new(self.to_hash.merge(data), @id)
    end

    def view
      data = self.to_hash
      data['identity'] = @identity.view if @identity
      data['image'] = @image.view if @image
      data
    end

    def self.inflate(record)
      if (record)
        data = record.dup
        data['identity'] = Lynr::Model::Identity.inflate(record['identity'])
        data['image'] = Lynr::Model::Image.inflate(record['image'])
        Lynr::Model::Dealership.new(data, record['id'])
      else
        nil
      end
    end

    protected

    def to_hash
      {
        'name' => @name,
        'phone' => @phone,
        'identity' => @identity,
        'address' => @address,
        'postcode' => @postcode,
        'image' => @image,
        'customer_id' => @customer_id
      }
    end

  end

end; end;
