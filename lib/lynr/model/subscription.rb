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

    attr_reader :canceled_at, :plan, :status

    # ## `Subscription.new(data)`
    #
    # Get `canceled_at`, `plan` and `status` out of `data`. `canceled_at` defaults
    # to nil `plan` defaults to empty string and `status` defaults to 'inactive'.
    # 'inactive' is nonsense as far as customer status is concerned and translates
    # to mean, "we don't have information about this customer".
    #
    def initialize(data={})
      @canceled_at = data.fetch('canceled_at', data.fetch(:canceled_at, nil))
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

    # ## `Subscription#demo?`
    #
    # True if this customer is on a demo account.
    #
    def demo?
      ['demo'].include?(status)
    end

    # ## `Subscription#ending?`
    #
    # True if this customer has request their account be canceled but there
    # is still time before the end of their billing cycle.
    #
    def ending?
      active? && !canceled_at.nil?
    end

    # ## `Subscription#set(data)`
    #
    # Merge `data` with current properties and create a new `Subscription`
    # instance from the result.
    #
    def set(data={})
      Subscription.new({
        canceled_at: data.fetch('canceled_at', data.fetch(:canceled_at, @canceled_at)),
        plan: data.fetch('plan', data.fetch(:plan, @plan)),
        status: data.fetch('status', data.fetch(:status, @status)),
      })
    end

    # ## `Subscription#view`
    #
    # Get a `Hash` representation of this instance.
    #
    def view
      {
        'canceled_at' => canceled_at,
        'plan' => plan,
        'status' => status,
      }
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
