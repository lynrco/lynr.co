require 'lynr/controller/admin'

module Lynr; module Controller;

  class AdminVin < Lynr::Controller::Admin

    post '/admin/:slug/vin/search',     :search

    def search(req)
      return unauthorized unless authorized?(req)
      dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @posted = req.POST.dup
      posted['dealership'] = dealership
      #vehicle = vehicle_dao.save(Lynr::Model::Vehicle.inflate(@posted))
      redirect "/admin/#{dealership.slug}/#{vehicle.slug}/edit"
    end

  end

end; end;
