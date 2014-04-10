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
      subscription = stripe_to_subscription(customer.subscription)
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

    desc 'Sync subscription status for `dealership` (slug or id)'
    task :sync_subscription, :dealership do |t, args|
      dealership_id = args[:dealership]
      dealership =
        if BSON::ObjectId.legal?(dealership_id)
          dealership_dao.get(BSON::ObjectId.from_string(dealership_id))
        else
          dealership_dao.get_by_slug(dealership_id)
        end
      sync_customer(dealership.customer_id)
    end

    desc 'Sync subscription status for all dealerships'
    task :sync_subscriptions do
      # NOTE: Requires knowledge of `Lynr::Persist::DealershipDao` internals
      collection = dealership_dao.instance_variable_get(:@dao)
      collection.search({}, fields: ['_id', 'customer_id']).each do |record|
        sync_customer(record['customer_id'])
      end
    end

  end

end
