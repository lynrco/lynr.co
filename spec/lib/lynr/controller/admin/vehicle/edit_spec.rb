require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/vehicle/edit'

describe Lynr::Controller::Admin::Vehicle::Edit do

  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  let(:path) { '/admin/:slug/:vehicle/edit' }
  let(:uri) { "/admin/#{saved_empty_dealership.id}/#{saved_empty_vehicle.id}/edit" }
  let(:env_opts) { { 'rack.session' => { 'dealer_id' => saved_empty_dealership.id } } }
  let(:full_uri) { "https://#{domain}#{uri}" }

  before(:each) do
    Lynr::Queue::JobQueue.any_instance.stub(:publish) do |job, opts|
      self
    end
  end

  context "GET /admin/:slug/:vehicle/edit" do

    let(:route_method) { [:get_edit_vehicle, 'GET'] }

    it_behaves_like "Lynr::Controller::Base#valid_request"

  end

  context "POST /admin/:slug/:vehicle/edit" do

    let(:route_method) { [:post_edit_vehicle, 'POST'] }
    let(:env_opts) {
      {
        method: route_method[1],
        params: { 'vin[ext_color]' => 'silver' },
        'rack.session' => { 'dealer_id' => saved_empty_dealership.id },
      }
    }

    it_behaves_like "Lynr::Controller::Base#valid_request", 302

  end

end
