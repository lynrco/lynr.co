require 'lynr/controller/admin'
require './lib/lynr/converter/data_one'

module Lynr; module Controller;

  class AdminVin < Lynr::Controller::Admin

    post '/admin/:slug/vin/search', :search

    def search(req)
      return unauthorized unless authorized?(req)
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @posted = req.POST.dup
      posted['dealership'] = @dealership
      query_response = fetch(posted['vin'])
      if query_response.nil?
        @base_menu = Lynr::View::Menu.new('Vehicle Menu', "", :menu_vehicle)
        @subsection = 'vehicle-add'
        @title = 'Add Vehicle'

        @errors = { 'vin' => 'Vin not found.' }
        render 'admin/vehicle/add.erb'
      else
        vehicle = vehicle_dao.save(Lynr::Converter::DataOne.xml_to_vehicle(query_response).set({ 'dealership' => @dealership }))
        redirect "/admin/#{@dealership.slug}/#{vehicle.slug}/edit"
      end
    end

    def fetch(vin)
      if File.exists?("spec/data/#{vin}.xml")
        doc = LibXML::XML::Document.file("spec/data/#{vin}.xml")
      else
        doc = LibXML::XML::Document.new
        node = LibXML::XML::Node.new 'query_response'
        doc.root = node
      end
      doc.find("//query_response[@identifier='#{vin}']").first
    end

  end

end; end;
