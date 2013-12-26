require 'libxml'
require 'rest-client'

require './lib/sly/view/erb'

require './lib/lynr'
require './lib/lynr/converter/libxml_helper'
require './lib/lynr/queue/job'
require './lib/lynr/persist/dealership_dao'

module Lynr; class Queue;

  class PostCraigslistJob < Job

    include Lynr::Converter::LibXmlHelper

    VALIDATE_URL = 'https://post.craigslist.org/bulk-rss/validate'
    POST_URL = 'https://post.craigslist.org/bulk-rss/post'
    XML_NAMESPACES = ['rss:http://purl.org/rss/1.0/']

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
      cl_validate.then(method(:cl_post))
    rescue RestClient::Exception => rce
      log.warn("#{self.info} message=`Post to #{url} failed... #{rce.to_s}`")
      failure("Post to #{url} failed. #{rce.to_s}")
    end

    private

    def cl_post
      response = send(POST_URL)
      # TODO: Verify response and mark vehicle as posted
      Success
    end

    def cl_validate
      response = send(VALIDATE_URL)
      # Quit if we didn't get a 200 response
      # TODO: Update vehicle posting status
      return failure("unsuccessful validation, aborting", :norequeue) if response.code != 200
      doc = LibXML::XML::Document.string(response.to_str)
      items = doc.find("/rdf:RDF/rss:item[@rdf:about=\"#{@vehicle.id.to_s}\"", XML_NAMESPACES)
      valid = items.length == 1 && contents(items.first, './cl:postedStatus').first == 'VALID'
      message = contents(items.first, './cl:postedExplanation').first
      # Quit if CL says we aren't valid
      # TODO: Update vehicle posting status
      # Quotes in failure message are goofy because of quotes in JobResult#info
      return failure("Failed CL validation' cl.message='#{message}'", :norequeue) if !valid
      Success
    end

    def render_data
      {
        dealership: dealership,
        vehicle: @vehicle,
        username: @username,
        password: @password
      }
    end

    def send(url)
      data = vehicle_rss
      headers = {
        'Content-type' => 'application/x-www-form-urlencoded',
        'Accept' => '*/*',
        'Cache-Control' => 'no-cache',
        'Pragma' => 'no-cache',
        'Content-length' => data.length
      }
      RestClient.post url, data, headers
    end

    def vehicle_rss
      @dealership = self.dealership
      view = Sly::View::Erb.new(::File.join(Lynr.root, 'views', 'admin/vehicle/craigslist.erb'), data: render_data )
      view.result
    end

  end

end; end;
