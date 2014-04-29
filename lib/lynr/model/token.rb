require './lib/lynr/model/base'

module Lynr::Model

  # # `Lynr::Model::Token`
  #
  # Represents an authentication token allowing a customer to login without
  # authenticating with a password.
  #
  class Token

    include Lynr::Model::Base

    attr_reader :id, :dealership, :expires, :next

    # ## `Token.new(data)`
    #
    # Create a new authentication token from fields in `data`.
    #
    # * `id` is the identifier provided when the token is saved.
    # * `dealership` is the identifier for the dealership being authenticated
    #   with this token
    # * `expires` is the timestamp after which this authentication token is no
    #   longer valid
    # * `next` is where to send the custerom after the login. Defaults to
    #   the customer's inventory screen
    #
    def initialize(data={})
      @id = data.fetch('id', nil)
      @dealership = data.fetch('dealership')
      @dealership = @dealership.id if @dealership.respond_to?(:id)
      # Defaults to 24 hours from now
      @expires = data.fetch('expires', Time.now + 86400)
      @next = data.fetch('next', "/admin/#{@dealership}")
    rescue KeyError
      raise ArgumentError.new('Token requires a dealership id')
    end

    # ## `Token#expired?`
    #
    # Check if current time is after the 'expires' time provided when constructing
    # this instance.
    #
    def expired?
      Time.now > @expires
    end

    # ## `Token#view`
    #
    # Provides a `Hash` representation of the data for this authentication
    # token.
    #
    def view
      {
        'id' => @id,
        'class' => self.class.name,
        'dealership' => @dealership,
        'expires' => @expires,
        'next' => @next
      }
    end

    # ## `Token.inflate(record)`
    #
    # Create a new authentication token from `record`.
    #
    def self.inflate(record)
      data = record || {}
      Token.new(data)
    end

    private

    # ## `Token#equality_fields`
    #
    # Provides an `Array` of attribute names used by `Lynr::Model::Base` to
    # determine equality of two token instances.
    #
    def equality_fields
      [:id, :dealership, :expires, :next]
    end

  end

end
