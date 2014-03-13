require 'json'

require './lib/lynr'
require './lib/lynr/controller/base'
require './lib/lynr/queue/email_job'

module Lynr; module Controller;

  # # `Lynr::Controller::Api`
  #
  # Controller for an API endpoint for the Lynr application. Processes a subset
  # of Stripe events.
  #
  class Api < Lynr::Controller::Base

    API_ROOT = '/api'
    API_VERSION = 'v1'
    API_BASE = "#{API_ROOT}/#{API_VERSION}"

    post "#{API_BASE}/stripe.webhook", :stripe_hook

    # ## `Api#stripe_hook(req)`
    #
    # Handle POST requests to stripe.webook by delegating to `#process_stripe_event`
    # if the live modes match.
    #
    def stripe_hook(req)
      json = JSON.parse(req.body.read)
      if json['livemode'] == Lynr::Web.config['stripe']['live']
        process_stripe_event(req, json)
      else
        Rack::Response.new("Live modes do not match")
      end
    end

    protected

    # ## `Api#process_stripe_event(json)`
    #
    # *Protected* Delegates to specific stripe handler methods based on
    # `json['type']`. If `json['type']` does not have a specific handler method
    # associated then an empty 200 response is returned.
    #
    def process_stripe_event(json, req)
      log.debug({ type: 'data', stripe_type: json['type'] })
      case json['type']
        when 'customer.deleted' then stripe_customer_deleted(json, req)
        when 'customer.subscription.trial_will_end' then stripe_customer_trial_ending(json, req)
      end
      Rack::Response.new
    end

    # ## `Api#stripe_customer_deleted(event)`
    #
    # Process the customer deleted event from Stripe by deleting the associated dealership.
    #
    def stripe_customer_deleted(event, req)
      customer = event['data']['object']
      id = customer['id']
      log.debug({ type: 'method', data: "stripe_customer_deleted -- #{id}" })
      dealership = dealer_dao.get_by_email(customer['email'])
      return false unless dealership && dealership.customer_id == id
      log.debug({ type: 'notice', message: "Found dealership with #{customer['email']} and #{id}" })
      stripe_customer = Stripe::Customer.retrieve(id)
      return false unless stripe_customer.deleted
      log.debug({ type: 'notice', message: "Verified #{id} was deleted with Stripe" })
      dealer_dao.delete(dealership.id)
    end

    # ## `Api#stripe_customer_trial_ending(event)`
    #
    # Process the customer trial ending event from Stripe by submitting a background
    # job which will email the customer.
    #
    def stripe_customer_trial_ending(event, req)
      obj = event['data']['object']
      id = obj['customer']
      log.debug({ type: 'method', data: "stripe_customer_trial_ending -- #{id}" })
      trial_end_date = Time.at(obj['trial_end'])
      dealership = dealer_dao.get_by_customer_id(id)
      return false unless dealership && dealership.customer_id == id
      # Schedule Email reminder to customer about trial ending
      Lynr.producer('email').publish(Lynr::Queue::EmailJob.new('trial_end', {
        to: dealership.identity.email,
        subject: "Lynr.co Trial Ends on #{trial_end_date.strftime('%B %d')}",
        base_url: req.base_url,
        end_date: trial_end_date,
      }))
    end

  end

end; end;
