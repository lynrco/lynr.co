namespace :lynr do

  namespace :stripe do

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
