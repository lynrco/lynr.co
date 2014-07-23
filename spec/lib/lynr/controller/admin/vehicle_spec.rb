require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/web'
require './lib/lynr/controller/admin/vehicle'

describe Lynr::Controller::Admin::Vehicle do

  context "with active connection", :if => (MongoHelpers.connected?) do

    include_context "spec/support/ModelHelper"
    include_context "spec/support/RouteHelper"

    let(:path) { '/admin/:slug/:vehicle' }

    # Test vehicle retrieval based on id
    describe "#vehicle" do

      let(:dealership) do
        saved_empty_dealership
      end

      let(:vehicle) do
        saved_empty_vehicle
      end

      it "retrieves an existing dealership when slug is id" do
        req = request("/admin/#{dealership.id}/#{vehicle.id}")
        expect(subject.vehicle(req)).to be_an_instance_of(Lynr::Model::Vehicle)
      end

      it "returns nil when id doesn't exist" do
        req = request("/admin/#{dealership.id}/#{BSON::ObjectId.from_time(Time.now)}")
        expect(subject.vehicle(req)).to be nil
      end

      it "returns nil when vehicle id is 'undefined'" do
        req = request("/admin/#{dealership.id}/undefined")
        expect(subject.vehicle(req)).to be nil
      end

    end

  end

end
