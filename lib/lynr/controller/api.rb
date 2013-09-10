require 'json'
require 'sly'
require 'lynr/controller/base'

module Lynr; module Controller;

  class Api < Lynr::Controller::Base

    post "#{Lynr::API_BASE}/stripe.webhook", :stripe_hook

    def stripe_hook(req)
      json = JSON.parse(req.body.read)
      if json['livemode'] == Lynr::Web.config['stripe']['live']
        process_stripe_event(json)
      else
        Rack::Response.new("Live modes do not match")
      end
    end

    protected

    def process_stripe_event(json)
      log.debug({ type: 'data', stripe_type: json['type'] })
      case json['type']
        when 'customer.deleted' then stripe_customer_deleted(json)
        when 'customer.subscription.trial_will_end' then stripe_customer_trial_ending(json)
      end
      Rack::Response.new
    end

    def stripe_customer_deleted(event)
      customer = event['data']['object']
      id = customer['id']
      log.debug({ type: 'method', data: "stripe_customer_deleted -- #{id}" })
      dao = Lynr::Persist::DealershipDao.new
      dealership = dao.get_by_email(customer['email'])
      return false unless dealership && dealership.customer_id == id
      log.debug({ type: 'notice', message: "Found dealership with #{customer['email']} and #{id}" })
      stripe_customer = Stripe::Customer.retrieve(id)
      return false unless stripe_customer.deleted
      log.debug({ type: 'notice', message: "Verified #{id} was deleted with Stripe" })
      dao.delete(dealership.id)
    end

    def stripe_customer_trial_ending(event)
      obj = event['data']['object']
      id = obj['customer']
      log.debug({ type: 'method', data: "stripe_customer_trial_ending -- #{id}" })
      dao = Lynr::Persist::DealershipDao.new
      dealership = dao.get_by_customer_id(id)
      return false unless dealership && dealership.customer_id == id
      # TODO: Email reminder to customer about trial ending
    end

  end

end; end;
