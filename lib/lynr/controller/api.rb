require 'json'
require 'stripe'

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
      if json['livemode'] == Lynr.config('app').stripe.live?
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
        when 'customer.subscription.updated' then stripe_customer_subscription_updated(json, req)
        when 'customer.subscription.trial_will_end' then stripe_customer_trial_ending(json, req)
        when 'invoice.payment_failed' then stripe_invoice_payment_failed(json, req)
      end
      Rack::Response.new
    end

    # ## `Api#stripe_invoice_payment_failed(event, req)`
    #
    # Process the invoice.payment_failed `event` and notify the customer of the
    # problem via email.
    #
    def stripe_invoice_payment_failed(event, req)
      invoice = event['data']['object']
      # NOTE: If no next attempt we are on the last, subscription will be cancelled
      return false unless invoice['next_payment_attempt']
      # NOTE: Make sure we didn't misfire this hook
      return false if invoice['paid']
      dealership = dealer_dao.get_by_customer_id(invoice['customer'])
      customer = Stripe::Customer.retrieve(dealership.customer_id)
      attempt = case invoice['attempt_count']
        when 1 then '1st'
        when 2 then '2nd'
        when 3 then '3rd'
      end
      Lynr.producer('job').publish(Lynr::Queue::EmailJob.new('payment/charge_failed', {
        to: dealership.identity.email,
        subject: "Lynr.co Charge Failed",
        base_url: req.base_url,
        attempt_count: attempt,
        last4: customer.active_card.last4,
        next_attempt: Time.at(invoice['next_payment_attempt']),
      }))
    end

    # ## `Api#stripe_customer_deleted(event, req)`
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

    # ## `Api#stripe_customer_subscription_created(event, req)`
    #
    # Update the `Subscription` data associated with a `Dealership` when
    # it is created in Stripe.
    #
    def stripe_customer_subscription_created(event, req)
      stripe_customer_subscription_updated(event, req)
    end

    # ## `Api#stripe_customer_subscription_updated(event, req)`
    #
    # Update the `Subscription` data associated with a `Dealership` when
    # it changes in Stripe.
    #
    def stripe_customer_subscription_updated(event, req)
      subscription = event['data']['object']
      subs = Lynr::Model::Subscription.new({
        canceled_at: subscription['canceled_at'],
        plan: subscription['plan']['id'],
        status: subscription['status'],
      })
      dealership = dealer_dao.get_by_customer_id(subscription['customer']).set('subscription' => subs)
      dealer_dao.save(dealership)
    end

    # ## `Api#stripe_customer_trial_ending(event, req)`
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
      Lynr.producer('job').publish(Lynr::Queue::EmailJob.new('trial_end', {
        to: dealership.identity.email,
        subject: "Lynr.co Trial Ends on #{trial_end_date.strftime('%B %d')}",
        base_url: req.base_url,
        end_date: trial_end_date,
      }))
    end

  end

end; end;
