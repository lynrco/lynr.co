require './lib/sly/view/erb'

require './lib/lynr'
require './lib/lynr/queue/job'
require './lib/lynr/persist/dealership_dao'

module Lynr; class Queue;

  class PostCraigslistJob < Job

    def initialize(vehicle)
      @username = 'bryan.j.swift@gmail.com'
      @password = 'bundle exec rake worker:all'
      @vehicle = vehicle
    end

    def data
      {
        dealership: dealership,
        vehicle: @vehicle,
        username: @username,
        password: @password
      }
    end

    def dealership
      return @dealership unless @dealership.nil?
      dao = Lynr::Persist::DealershipDao.new
      dao.get(@vehicle.dealership_id)
    end

    def render
      @dealership = self.dealership
      view = Sly::View::Erb.new(::File.join(Lynr.root, 'views', 'admin/vehicle/craigslist.erb'), data: data )
      view.result
    end

  end

end; end;
