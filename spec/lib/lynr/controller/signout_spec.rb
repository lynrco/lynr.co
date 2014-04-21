require 'rack'
require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/signout'

describe Lynr::Controller::Signout do

  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  let(:path) { '/signout' }
  let(:uri) { "/signout" }

  context "GET /signout" do

    context "with session" do
      let(:session) {
        session = double("Rack::Session::Abstract::SessionHash")
        allow(session).to receive(:destroy) { nil }
        session
      }
      let(:env_opts) do
        { 'rack.session' => session }
      end
      it_behaves_like "Lynr::Controller::Base#valid_request", 302
    end

  end

end
