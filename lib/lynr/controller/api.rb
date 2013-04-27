require 'json'
require 'sly'
require 'lynr/controller/base'

module Lynr; module Controller;

  class Api < Lynr::Controller::Base

    post "#{Lynr::App::API_BASE}/stripe.webhook", :stripe_hook

    def stripe_hook(req)
      json = JSON.parse(req.body.read)
      log.debug({ type: 'data', stripe_type: json['type'] })
      case json['type']
      when 'customer.deleted' then stripe_customer_deleted(json)
      end
      Rack::Response.new(status = 200)
    end

    protected

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

  end

end; end;
