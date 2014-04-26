require './lib/lynr/persist/exceptions'
require './lib/lynr/persist/mongo_dao'
require './lib/lynr/model/dealership'

module Lynr; module Persist;

  # # `Lynr::Persist::DealershipDao`
  #
  # Data Access Object specialized to interact with `Lynr::Model::Dealership`
  # instances.
  #
  class DealershipDao

    # ## `DealershipDao.new`
    #
    # Establish a connection to backing database and create indices if they
    # don't exist.
    #
    def initialize
      @collection = 'dealers'
      @dao = MongoDao.new('collection' => @collection)
      @indexed = false
      ensure_indices if @dao.active?
    end

    # ## `DealershipDao#account_exists?(email)`
    #
    # Check to see if `email` is used by an existing account.
    #
    def account_exists?(email)
      @dao.collection.count(query: { 'identity.email' => email }, read: :secondary, limit: 1) > 0
    end

    # ## `DealershipDao#delete(id)`
    #
    # Delete (or archive) the record identified by `id`.
    #
    def delete(id)
      # TODO: Implement this for Stripe webhooks
    end

    # ## `DealershipDao#get(id)`
    #
    # Retrieve the `Dealership` identified by `id`.
    #
    def get(id)
      record =
        if (id.is_a?(BSON::DBRef) && id.namespace == @collection)
          @dao.db.dereference(id)
        elsif (id.is_a?(String) && BSON::ObjectId.legal?(id))
          @dao.read(BSON::ObjectId.from_string(id))
        else
          @dao.read(id)
        end
      # Mongo is going to give me a record with the _id property set, not id
      translate(record)
    end

    # ## `DealershipDao#get_by_customer_id(customer_id)`
    #
    # Retrieve the `Dealership` identified by `customer_id`.
    #
    def get_by_customer_id(customer_id)
      record = @dao.search({ 'customer_id' => customer_id }, { limit: 1 })
      translate(record)
    end

    # ## `DealershipDao#get_by_email(email)`
    #
    # Retrieve the `Dealership` identified by `email`.
    #
    def get_by_email(email)
      record = @dao.search({ 'identity.email' => email }, { limit: 1 })
      translate(record)
    end

    # ## `DealershipDao#get_by_slug(slug)`
    #
    # Retrieve the `Dealership` identified by `slug`
    #
    def get_by_slug(slug)
      record = @dao.search({ 'slug' => slug }, { limit: 1 })
      translate(record)
    end

    # ## `DealershipDao#save(dealer)`
    #
    # Create a new record for `dealer` or update the record associated with it.
    #
    def save(dealer)
      record = @dao.save(dealer.view, dealer.id)
      translate(record)
    rescue Mongo::MongoDBError => dberror
      raise Lynr::Persist::MongoUniqueError.new(dberror)
    end

    def slug_exists?(slug)
      @dao.collection.count(query: { 'slug' => slug }, read: :secondary, limit: 1) > 0
    end

    private

    # ## `DealershipDao#ensure_indices`
    #
    # Create appropriate indexes on the database structure backing this 'table'.
    #
    def ensure_indices
      @dao.collection.ensure_index(
        [['identity.email', Mongo::ASCENDING]],
        index_options([:background, :unique])
      )
      @dao.collection.ensure_index([['customer_id', Mongo::ASCENDING]], index_options)
      @dao.collection.ensure_index([['slug', Mongo::ASCENDING]], index_options([]))
      @indexed = true
    end

    # ## `DealershipDao#index_options(keys)`
    #
    # Create a `Hash` of options for the array of keys provided. Each
    # value in `keys` is mapped to `true`.
    #
    def index_options(keys=[:background, :unique, :sparse])
      Hash[ keys.map { |k| [k, true] } ]
    end

    # ## `DealershipDao#translate(record)`
    #
    # Take a record `Hash` provided by the database and turn it into a `Dealership`
    # instance.
    #
    def translate(record)
      record['id'] = record.delete('_id') if !record.nil?
      Lynr::Model::Dealership.inflate(record)
    end

  end

end; end;
