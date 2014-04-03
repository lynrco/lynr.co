require 'libxml'
require 'rest-client'

require './lib/data_one'

require './lib/lynr'
require './lib/lynr/controller/admin'
require './lib/lynr/converter/data_one'
require './lib/lynr/queue/index_vehicle_job'

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
      query_response = DataOne::Api.fetch(posted['vin'].upcase)
      if query_response.nil?
        @subsection = 'vehicle-add'
        @title = 'Add Vehicle'

        @errors = { 'vin' => 'Vin not found.' }
        render 'admin/vehicle/add.erb'
      else
        vehicle = save_vehicle(xml_to_vehicle(query_response).set({
          'dealership' => @dealership
        }))
        redirect "/admin/#{@dealership.slug}/#{vehicle.slug}/edit"
      end
    end

  end

end; end;
