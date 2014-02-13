require 'libxml'
require 'rest-client'

require './lib/lynr/controller/admin'
require './lib/lynr/converter/data_one'

module Lynr; module Controller;

  # # `Lynr::Controller::AdminVin`
  #
  # Controller to process requests for the vin search resource.
  #
  class AdminVin < Lynr::Controller::Admin

    include Lynr::Converter::DataOne

    post '/admin/:slug/vin/search', :search

    # ## `AdminVin#search(req)`
    #
    # Process POST requests for VIN search by fetching data from the DataOne
    # back end. If a vehicle is found with the provided VIN then create a new
    # `Lynr::Model::Vehicle` based on the provided data, save it and redirect
    # to the edit page for the newly created vehicle. If no data is found for
    # the provided VIN then display an error on the add vehicle page notifying
    # the customer.
    #
    def search(req)
      posted['dealership'] = @dealership
      query_response = fetch(posted['vin'])
      if query_response.nil?
        @base_menu = Lynr::View::Menu.new('Vehicle Menu', "", :menu_vehicle)
        @subsection = 'vehicle-add'
        @title = 'Add Vehicle'

        @errors = { 'vin' => 'Vin not found.' }
        render 'admin/vehicle/add.erb'
      else
        vehicle = vehicle_dao.save(xml_to_vehicle(query_response).set({
          'dealership' => @dealership
        }))
        redirect "/admin/#{@dealership.slug}/#{vehicle.slug}/edit"
      end
    end

    # ## `AdminVin#fetch(vin)`
    #
    # Retrieve vehicle data from the the DataOne back end and return a
    # `LibXML::XML::Node` with the `<query_response />` element from the data.
    #
    def fetch(vin)
      if File.exists?("spec/data/#{vin}.xml")
        doc = LibXML::XML::Document.file("spec/data/#{vin}.xml")
      elsif Lynr.config('features').dataone_decode
        doc = LibXML::XML::Document.string(fetch_dataone(vin))
      else
        doc = LibXML::XML::Document.new
        node = LibXML::XML::Node.new 'query_response'
        doc.root = node
      end
      doc.find("//query_response[@identifier='#{vin}']").first
    end

    def fetch_dataone(vin)
      config = Lynr.config('app').vin.dataone
      url = config.url
      data = {
        authorization_code: config.auth_code,
        client_id:          config.client_id,
        decoder_query:      dataone_xml_query(vin),
      }
      RestClient.post url, data
    end

    protected

    # ## `AdminVin#dataone_xml_query(vin)`
    #
    # *Protected* Helper method to render query template with the appropriate `vin` data.
    #
    def dataone_xml_query(vin)
      path = ::File.join(Lynr.root, 'views/admin/vehicle/dataone_request')
      Sly::View::Erb.new(path, data: { vin: vin }).result
    end

  end

end; end;
