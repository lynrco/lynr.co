require 'lynr/persist/mongo_dao'
require 'lynr/model/dealership'

module Lynr; module Persist;

  class DealershipDao

    def initialize
      @dao = MongoDao.new('collection' => 'dealers')
      @dao.collection.ensure_index([['identity.email', Mongo::ASCENDING]], { unique: true })
      @dao.collection.ensure_index([['customer_id', Mongo::ASCENDING]], { unique: true })
    end

    def account_exists?(email)
      @dao.collection.count(query: { 'identity.email' => email }, read: :secondary, limit: 1) > 0
    end

    def delete(id)
      # TODO: Implement this for Stripe webhooks
    end

    def get(id)
      record = @dao.read(id)
      # Mongo is going to give me a record with the _id property set, not id
      translate(record)
    end

    def get_by_customer_id(customer_id)
      record = @dao.search({ 'customer_id' => customer_id }, { limit: 1 })
      translate(record)
    end

    def get_by_email(email)
      record = @dao.search({ 'identity.email' => email }, { limit: 1 })
      translate(record)
    end

    def save(dealer)
      record = @dao.save(dealer.view, dealer.id)
      Lynr::Model::Dealership.inflate(record)
    end

    private

    def translate(record)
      record['id'] = record.delete('_id') if !record.nil?
      Lynr::Model::Dealership.inflate(record)
    end

  end

end; end;
