require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/ping'

describe Lynr::Controller::Ping do

  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  let(:path) { '/ping' }
  let(:uri) { "/ping" }

  context "GET /ping" do

    let(:route_method) { [:ping, 'GET'] }
    let(:response) { route.call(env) }
    let(:headers) { response[1] }

    it_behaves_like "Lynr::Controller::Base#valid_request"

    it { expect(headers).to include('Content-Type') }

    it { expect(headers['Content-Type']).to match(/text\/plain/) }

    it { expect(response[2].body).to include('PONG') }

  end

end
