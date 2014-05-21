require 'stripe'

require './lib/lynr'
require './lib/lynr/model/dealership'
require './lib/lynr/queue/job'

module Lynr; class Queue;

  # # `Lynr::Queue::StripeUpdateJob`
  #
  # `Job` which, when executed successfully, updates the customer data stored with
  # Stripe to the most recent information attached to dealership.
  #
  class StripeUpdateJob < Job

    # ## `Lynr::Queue::StripeUpdateJob.new(dealership)`
    #
    # Create a `Job` to update data stored with Stripe for `dealership`.
    #
    def initialize(dealership)
      @dealership = dealership
    end

    # ## `Lynr::Queue::StripeUpdateJob#perform`
    #
    # Retrieve the customer data from Stripe and then save the customer data from
    # `dealership` passed to constructor to the Strip customer.
    #
    def perform
      setup if Stripe.api_key.nil? || Stripe.api_version.nil?
      customer = Stripe::Customer.retrieve(@dealership.customer_id)
      customer.description = @dealership.name
      customer.email = @dealership.identity.email
      customer.save
      Success
    end

    # ## `Lynr::Queue::StripeUpdateJob#setup`
    #
    # Setup the Stripe gem with config values. Only needs to be called once per thread
    # but should be indempotent.
    #
    def setup
      config = Lynr.config('app').fetch('stripe', {})
      Stripe.api_key = config['key']
      Stripe.api_version = config.fetch('version', '2013-02-13')
    end

  end

end; end;
