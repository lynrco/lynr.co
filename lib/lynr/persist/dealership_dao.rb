require './lib/lynr/persist/mongo_dao'
require './lib/lynr/model/dealership'

module Lynr; module Persist;

  class DealershipDao

    def initialize
      @collection = 'dealers'
      @dao = MongoDao.new('collection' => @collection)
      @indexed = false
      ensure_indices if @dao.active?
    end

    def account_exists?(email)
      @dao.collection.count(query: { 'identity.email' => email }, read: :secondary, limit: 1) > 0
    end

    def delete(id)
      # TODO: Implement this for Stripe webhooks
    end

    def get(id)
      record =
        if (id.is_a?(BSON::DBRef) && id.namespace == @collection)
          @dao.db.dereference(id)
        else
          @dao.read(id)
        end
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
      translate(record)
    end

    private

    def ensure_indices
      @dao.collection.ensure_index([['identity.email', Mongo::ASCENDING]], { unique: true })
      @dao.collection.ensure_index([['customer_id', Mongo::ASCENDING]], { unique: true })
      @indexed = true
    end

    def translate(record)
      record['id'] = record.delete('_id') if !record.nil?
      Lynr::Model::Dealership.inflate(record)
    end

  end

end; end;
