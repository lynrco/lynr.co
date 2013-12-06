require 'bson'

require './lib/lynr/model/address'
require './lib/lynr/model/base'
require './lib/lynr/model/base_dated'
require './lib/lynr/model/identity'
require './lib/lynr/model/sized_image'

module Lynr; module Model;

  # `Dealership.new` takes a `Hash` containing data to set into the object.
  #
  # * `name` of the dealership
  # * `phone` number to reach the dealership
  # * `identity` instance of `Lynr::Model::Identity containing credentials
  #   for logging in as this dealership
  # * `address` on the street of the dealership, where to find the vehicles
  # * `image` instance of `Lynr::Model::SizedImage`
  # * `customer_id` from payment processor, how to identify payment details
  # * `created_at` date when this dealership instance was created
  # * `updated_at` date when this dealership instance was last updated
  class Dealership

    include Lynr::Model::Base
    include Lynr::Model::BaseDated

    attr_reader :id, :created_at, :updated_at
    attr_reader :name, :phone, :identity, :address, :postcode, :image, :customer_id

    def initialize(data={}, id=nil)
      @id = id
      @name = data.fetch('name', default="")
      @phone = data.fetch('phone', default="")
      @identity = data.fetch('identity', default=nil)
      @address = data.fetch('address', default="")
      @postcode = data.fetch('postcode', default="")
      @image = data.fetch('image', default=nil)
      @customer_id = data.fetch('customer_id', default=nil)
      @created_at = data.fetch('created_at', default=nil)
      @updated_at = data.fetch('updated_at', default=nil)
    end

    def set(data={})
      Lynr::Model::Dealership.new(self.to_hash.merge(data), @id)
    end

    def slug
      id.to_s
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
        data['address'] =
          if data['address'].is_a? Hash
            Lynr::Model::Address.inflate(data['address'])
          else
            Lynr::Model::Address.new('line_one' => record['address'], 'zip' => record['postcode'])
          end
        data['identity'] = Lynr::Model::Identity.inflate(record['identity'])
        data['image'] = Lynr::Model::SizedImage.inflate(record['image'])
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
        'customer_id' => @customer_id,
        'created_at' => @created_at,
        'updated_at' => @updated_at
      }
    end

    private

    def extract_address(data)
      if data['address'].is_a? Lynr::Model::Address
        data['address']
      elsif data['address'].is_a? Hash
        Lynr::Model::Address.inflate(data['address'])
      else
        Lynr::Model::Address.new('line_one' => data['address'], 'zip' => data['postcode'])
      end
    end

  end

end; end;
