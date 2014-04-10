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
      # TODO: If the subscription is already canceled then render 'admin/account/canceled.erb'
      render 'admin/account/cancel.erb'
    end

    # ## `AdminAccountCancel#post(req)`
    #
    # Process POST requests by notifying Strip of the account cancelation.
    #
    def post(req)
      customer = Stripe::Customer.retrieve(dealership(req).customer_id)
      subscription =
        if customer.subscription.cancel_at_period_end
          customer.subscription
        else
          customer.subscription.delete(at_period_end: true)
        end
      @active_until = Time.at(subscription.current_period_end)
      render 'admin/account/canceled.erb'
    end

  end

end
