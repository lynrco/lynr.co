require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/inventory'

describe Lynr::Controller::Admin::Inventory do

  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  let(:env_opts) { { 'rack.session' => { 'dealer_id' => saved_empty_dealership.id } } }
  let(:full_uri) { "https://#{domain}#{uri}" }

  context "GET /admin/:slug" do

    let(:path) { '/admin/:slug' }
    let(:uri) { "/admin/#{saved_empty_dealership.id}" }
    let(:route_method) { [:inventory, 'GET'] }

    it_behaves_like "Lynr::Controller::Base#valid_request" if MongoHelpers.connected?

  end

  context "GET /menu/:slug" do

    let(:path) { '/menu/:slug' }
    let(:uri) { "/menu/#{saved_empty_dealership.id}" }
    let(:route_method) { [:menu, 'GET'] }

    it_behaves_like "Lynr::Controller::Base#valid_request" if MongoHelpers.connected?

  end

end
