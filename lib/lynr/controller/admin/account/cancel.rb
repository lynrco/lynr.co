require './lib/lynr'
require './lib/lynr/controller'
require './lib/lynr/controller/admin'

module Lynr::Controller

  # # `Lynr::Controller::AdminAccountCancel`
  #
  # Handle the logic of marking accounts for cancelation.
  #
  class AdminAccountCancel < Lynr::Controller::Admin

    get  '/admin/:slug/account/cancel', :get
    post '/admin/:slug/account/cancel', :post

    # ## `AdminAccountCancel#before_each(req)`
    #
    # Set up universal attributes
    #
    def before_each(req)
      super
      @subsection = 'account account-cancel'
      @title = "Cancel Account"
    end

    # ## `AdminAccountCancel#get(req)`
    #
    # Process GET requests.
    #
    def get(req)
      if dealership(req).subscription.ending?
        customer = Stripe::Customer.retrieve(dealership(req).customer_id)
        subscription = current_subscription(customer)
        @active_until = Time.at(subscription.current_period_end)
        render 'admin/account/canceled.erb'
      else
        render 'admin/account/cancel.erb'
      end
    end

    # ## `AdminAccountCancel#post(req)`
    #
    # Process POST requests by notifying Strip of the account cancelation.
    #
    def post(req)
      customer = Stripe::Customer.retrieve(dealership(req).customer_id)
      subscription =
        if current_subscription(customer).cancel_at_period_end
          current_subscription(customer)
        else
          current_subscription(customer).delete(at_period_end: true)
        end
      dealer_dao.save(dealership(req).set({
        'subscription' => dealership(req).subscription.set(canceled_at: subscription.canceled_at)
      }))
      @active_until = Time.at(subscription.current_period_end)
      render 'admin/account/canceled.erb'
    end

    # ## `AdminAccountCancel#current_subscription(customer)`
    #
    # Internal: Get the current subscription from `customer`. The
    # current subscription is retrieved by cheating because right now
    # a customer may only have a single subscription.
    #
    # * `customer` - `Stripe::Customer` instance from which to retrieve
    #                subscription
    #
    # Returns a `Stripe::Subscription` instance from the `Stripe::Customer`
    # by finding the one that is currently active.
    #
    def current_subscription(customer)
      customer.subscriptions.first
    end

  end

end
