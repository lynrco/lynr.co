require 'rest-client'

require './lib/sly/view/erb'

require './lib/lynr'
require './lib/lynr/queue/job'
require './lib/lynr/persist/dealership_dao'

module Lynr; class Queue;

  class PostCraigslistJob < Job

    VALIDATE_URL = 'https://post.craigslist.org/bulk-rss/validate'
    POST_URL = 'https://post.craigslist.org/bulk-rss/post'

    def initialize(vehicle)
      @username = 'bryan.j.swift@gmail.com'
      @password = 'bundle exec rake worker:all'
      @vehicle = vehicle
    end

    def dealership
      return @dealership unless @dealership.nil?
      dao = Lynr::Persist::DealershipDao.new
      dao.get(@vehicle.dealership_id)
    end

    def perform
      data = vehicle_rss
      headers = {
        'Content-type' => 'application/x-www-form-urlencoded',
        'Accept' => '*/*',
        'Cache-Control' => 'no-cache',
        'Pragma' => 'no-cache',
        'Content-length' => data.length
      }
      url = VALIDATE_URL
      @response = RestClient.post url, data, headers
      # TODO: Verify response and mark vehicle as posted
      Success
    rescue RestClient::Exception => rce
      log.warn("#{self.info} message=`Post to #{url} with #{data} failed... #{rce.to_s}`")
      failure("Post to #{url} failed. #{rce.to_s}")
    end

    def render_data
      {
        dealership: dealership,
        vehicle: @vehicle,
        username: @username,
        password: @password
      }
    end

    def vehicle_rss
      @dealership = self.dealership
      view = Sly::View::Erb.new(::File.join(Lynr.root, 'views', 'admin/vehicle/craigslist.erb'), data: render_data )
      view.result
    end

  end

end; end;
