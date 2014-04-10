require './lib/lynr/model/base'

module Lynr::Model

  # # `Lynr::Model::Subscription`
  #
  # Holds information about the customer's subscription to Lynr.
  # Specifically it is used to query the customer's current subscription
  # status.
  #
  class Subscription

    include Base

    attr_reader :plan, :status

    # ## `Subscription.new(data)`
    #
    # Get `plan` and `status` out of `data`. `plan` defaults to empty
    # string and `status` defaults to 'inactive'. 'inactive' is nonsense
    # as far as customer status is concerned and translates to mean,
    # "we don't have information about this customer".
    #
    def initialize(data={})
      @plan = data.fetch('plan', data.fetch(:plan, ''))
      @status = data.fetch('status', data.fetch(:status, 'inactive'))
    end

    # ## `Subscription#active?`
    #
    # True if this is a customer in good standing.
    #
    def active?
      ['active', 'trialing'].include?(status)
    end

    # ## `Subscription#canceled?`
    #
    # True if this is a former customer, i.e. they are no longer paying
    # for the service.
    #
    def canceled?
      ['canceled', 'unpaid'].include?(status)
    end

    # ## `Subscription#delinquent?`
    #
    # True if this customer has a past due invoice.
    #
    def delinquent?
      ['past_due'].include?(status)
    end

    def set(data={})
      Subscription.new({
        plan: data.fetch('plan', data.fetch(:plan, @plan)),
        status: data.fetch('status', data.fetch(:status, @status)),
      })
    end

    # ## `Subscription#view`
    #
    # Get a `Hash` representation of this instance.
    #
    def view
      { 'plan' => plan, 'status' => status }
    end

    # ## `Subscription.inflate(record)`
    #
    # Turn record into a `Subscription` instance. Delegates to `.new`.
    #
    def self.inflate(record)
      Subscription.new(record || {})
    end

    protected

    # ## `Subscription#equality_fields`
    #
    # Array of fields to check in order to determine the equality of two
    # `Subscription` instances.
    #
    def equality_fields
      [:status, :plan]
    end

  end

end
