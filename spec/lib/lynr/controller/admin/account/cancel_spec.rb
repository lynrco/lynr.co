require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/account/cancel'

describe Lynr::Controller::AdminAccountCancel do

  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  let(:path) { '/admin/:slug/account/cancel' }
  let(:uri) { "/admin/#{saved_empty_dealership.id}/account/cancel" }
  let(:env_opts) { { 'rack.session' => { 'dealer_id' => saved_empty_dealership.id } } }

  context "GET /admin/:slug/account/cancel" do

    let(:route_method) { [:get, 'GET'] }
    let(:response) { route.call(env) }
    let(:headers) { response[1] }

    it_behaves_like "Lynr::Controller::Base#valid_request" if MongoHelpers.connected?

    it { expect(headers).to include('Content-Type') }

    it { expect(headers['Content-Type']).to match(/text\/html/) }

  end

end
