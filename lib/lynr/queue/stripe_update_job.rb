require 'stripe'

require 'lynr'
require 'lynr/queue/job'

module Lynr; class Queue;

  class StripeUpdateJob < Job

    def initialize(dealership)
      @dealership = dealership
    end

    def perform
      setup if Stripe.api_key.nil? || Stripe.api_version.nil?
      customer = Stripe::Customer.retrieve(@dealership.customer_id)
      customer.description = posted['name']
      customer.email = posted['email']
      customer.save
    end

    def setup
      config = Lynr.config('app')
      Stripe.api_key = config['stripe']['key']
      Stripe.api_version = config['stripe']['version'] || '2013-02-13'
    end

  end

end; end;
