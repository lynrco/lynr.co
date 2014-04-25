namespace :lynr do

  namespace :db do

    require './lib/lynr'
    require './lib/lynr/persist/dealership_dao'
    require './lib/lynr/persist/vehicle_dao'

    # Shortcut to a new `Lynr::Persist::DealershipDao`
    def dealership_dao
      @dealership_dao ||= Lynr::Persist::DealershipDao.new
    end

    def vehicle_dao
      @vehicle_dao ||= Lynr::Persist::VehicleDao.new
    end

  end

end
