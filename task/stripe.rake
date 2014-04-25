namespace :lynr do

  namespace :stripe do

    require 'stripe'
    require './lib/lynr'
    require './lib/lynr/persist/dealership_dao'

    Stripe.api_key = Lynr.config('app').stripe.key
    Stripe.api_version = Lynr.config('app').stripe.version

    # Shortcut to a new `Lynr::Persist::DealershipDao`
    def dealership_dao
      @dealership_dao ||= Lynr::Persist::DealershipDao.new
    end

    # Get customer information from Stripe and save it
    def sync_customer(customer_id)
      puts "Syncing subscription status from Stripe for #{customer_id}"
      customer = Stripe::Customer.retrieve(customer_id)
      dealer = dealership_dao.get_by_customer_id(customer_id)
      subscription = stripe_to_subscription(customer.subscriptions.first)
      dealership_dao.save(dealer.set({ 'subscription' => subscription }))
    end

    # Turn `Stripe::Subscription` into `Lynr::Model::Subscription`
    def stripe_to_subscription(subscription)
      record =
        if subscription.nil? || subscription.plan.nil?
          { plan: 'unknown', status: 'inactive' }
        else
          {
            canceled_at: subscription.canceled_at,
            plan: subscription.plan.id,
            status: subscription.status
          }
        end
      Lynr::Model::Subscription.new(record)
    end

  end

end
