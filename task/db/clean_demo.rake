namespace :lynr do

  namespace :db do

    desc 'Remove demo dealerships created more than a week ago'
    task :clean_demo do
      def candidates
        threshold = Time.now - (60*60*24*7)
        query = {
          'created_at' => { '$lt' => threshold },
          'subscription.status' => 'demo',
          'customer_id' => nil
        }
        dealers.search(query, { fields: ['_id', 'created_at'] })
      end
      def dealers() dealership_dao.instance_variable_get(:@dao) end
      def remove_vehicle(vehicle)
        result = vehicles.delete(vehicle['_id'])
        if write_success?(result)
          puts "Removed vehicle:#{vehicle['_id']} from dealer:#{vehicle['dealership']}"
        end
        write_success?(result)
      end
      def remove_dealer(dealer)
        result = dealers.delete(dealer['_id'])
        if write_success?(result)
          puts "Removed dealer:#{dealer['_id']}"
        end
        write_success?(result)
      end
      def vehicles() vehicle_dao.instance_variable_get(:@dao) end
      def vehicles_for(dealership)
        query = { 'dealership' => dealership['_id'] }
        options = { fields: ['_id', 'dealership'] }
        vehicles.search(query, options)
      end
      def write_success?(result)
        result['ok'] && result['err'].nil?
      end

      candidates.each do |dealer|
        puts "Removing vehicles for dealer:#{dealer['_id']} created at #{dealer['created_at']}"

        success = vehicles_for(dealer).reduce(true) do |success, vehicle|
          success && remove_vehicle(vehicle)
        end

        if success
          puts "Removed vehicles for dealer:#{dealer['_id']}"
          remove_dealer(dealer)
        end
      end
    end

  end

end
