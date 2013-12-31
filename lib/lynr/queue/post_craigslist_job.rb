require 'libxml'
require 'rest-client'

require './lib/sly/view/erb'

require './lib/lynr'
require './lib/lynr/converter/libxml_helper'
require './lib/lynr/queue/job'
require './lib/lynr/persist/dealership_dao'

module Lynr; class Queue;

  # # `Lynr::Queue::PostCraigslistJob
  #
  # Background `Job` to post data to validate a vehicle posting with Craigslist
  # and then post the listing to the appropriate category using the Craigslist
  # bulk posting interface API endpoints documented at
  # [http://www.craigslist.org/about/bulk_posting_interface][bpi].
  #
  # [bpi]: http://www.craigslist.org/about/bulk_posting_interface
  #
  class PostCraigslistJob < Job

    include Lynr::Converter::LibXmlHelper

    # URL to post to for validation
    VALIDATE_URL = 'https://post.craigslist.org/bulk-rss/validate'
    # URL to post to for posting
    POST_URL = 'https://post.craigslist.org/bulk-rss/post'
    # XML Namepsaces used in validation and posting responses.
    XML_NAMESPACES = ['rss:http://purl.org/rss/1.0/']

    # ## `Lynr::Queue::PostCraigslistJob.new(vehicle)`
    #
    # Create a new `PostCraigslistJob` to send a vehicle posting to Craigslist.
    #
    def initialize(vehicle)
      @username = 'bryan.j.swift@gmail.com'
      @password = 'bundle exec rake worker:all'
      @vehicle = vehicle
    end

    # ## `Lynr::Queue::PostCraigslistJob#dealership`
    #
    # Retrieve the dealership associated with `vehicle` given to constructor.
    #
    def dealership
      return @dealership unless @dealership.nil?
      dao = Lynr::Persist::DealershipDao.new
      dao.get(@vehicle.dealership_id)
    end

    # ## `Lynr::Queue::PostCraigslistJob#perform`
    #
    # Send `vehicle` data in the Craigslist RSS format to the validation endpoint.
    # If `vehicle` is successfully validated then send the same `vehicle` data to
    # the posting endpoint.
    #
    def perform
      cl_validate.then(method(:cl_post))
    rescue RestClient::Exception => rce
      log.warn("#{self.info} message=`Post to #{url} failed... #{rce.to_s}`")
      failure("Post to #{url} failed. #{rce.to_s}")
    end

    private

    # ## `Lynr::Queue::PostCraigslistJob#cl_post`
    #
    # *Private* method to send data to the `POST_URL` and return `Job::Success` if
    # everything goes smoothly.
    #
    def cl_post
      response = send(POST_URL)
      # TODO: Verify response and mark vehicle as posted
      Success
    end

    # ## `Lynr::Queue::PostCraigslistJob#cl_validate`
    #
    # *Private* method to send data to the `VALIDATE_URL` and return `Job::Success`
    # if `vehicle` is successfully validated.
    #
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

    # ## `Lynr::Queue::PostCraigslistJob#render_data`
    #
    # *Private* method to provides the data passed to `Sly::View::Erb` to render
    # `vehicle` in the bulk posting api's RSS format.
    #
    def render_data
      {
        dealership: dealership,
        vehicle: @vehicle,
        username: @username,
        password: @password
      }
    end

    # ## `Lynr::Queue::PostCraigslistJob#send(url)`
    #
    # *Private* method using `RestClient` to send `#vehicle_rss` to a CL endpoint
    # at `url` and return the response as a `RestClient::Response`.
    #
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

    # ## `Lynr::Queue::PostCraigslistJob#vehicle_rss`
    #
    # *Private* method to get `vehicle` given when constructing this Job as a bulk
    # posting api compaitble xml format.
    #
    def vehicle_rss
      @dealership = self.dealership
      path = ::File.join(Lynr.root, 'views', 'admin/vehicle/craigslist.erb')
      view = Sly::View::Erb.new(path, data: render_data)
      view.result
    end

  end

end; end;
