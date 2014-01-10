require 'time'

require './lib/lynr/model/base'

module Lynr::Model

  # # `Lynr::Model::EbayAccount`
  #
  # Representation of fields necessary to authenticate calls made on a customer's behalf
  # with the eBay API.
  #
  class EbayAccount
  
    include Lynr::Model::Base

    TYPE = 'eBay'

    attr_reader :expires, :session, :token

    # ## `EbayAccount.new(data)`
    #
    # Contruct an `EbayAccount` from a `Hash` of fields. Raises an error if `data` is `nil`.
    #
    # * `expires` String representing the `DateTime` when the auth token expires
    # * `session` SessionID used to get the auth token
    # * `token`   Authentication token
    #
    def initialize(data={})
      @expires = data.fetch('expires', default=DateTime.parse('Feb 11 13:32:16 2013 -0500'))
      @session = data.fetch('session', default="")
      @token = data.fetch('token', default="")
    end

    # ## `EbayAccount#empty?`
    #
    # False if and only if token and session both contain a value.
    #
    def empty?
      @session.nil? || @session.empty? || @token.nil? || @token.empty?
    end

    # ## `EbayAccount#expired?`
    #
    # False if and only if value of `expires` is later than now.
    #
    def expired?
      expires.nil? || expires <= DateTime.now
    end

    # ## `EbayAccount#view`
    #
    # Get a `Hash` representation of the `EbayAccount`
    #
    def view
      { 'expires' => expires, 'session' => session, 'token' => token, 'type' => TYPE, }
    end

    # ## `EbayAccount.inflate(record)`
    #
    # Create a new `EbayAccount` instance from a `record` Hash. Handles `nil`
    #
    def self.inflate(record)
      data = record || {}
      Lynr::Model::EbayAccount.new(data)
    end

    private

    # ## `EbayAccount#equality_fields`
    #
    # `Array` of accessor methods to compare to determine equality of two
    # `EbayAccount` instances.
    #
    def equality_fields
      [:expires, :token]
    end

  end

end
