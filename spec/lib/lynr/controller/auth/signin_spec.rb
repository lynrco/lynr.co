require 'rspec/autorun'
require 'stripe_mock'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/auth/signin'

describe Lynr::Controller::Auth::Signin do

  include_context "spec/support/ConfigHelper"
  include_context "spec/support/DemoHelper"
  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  subject(:controller) {
    Lynr::Controller::Auth::Signin.new
  }

  let(:path) { '/signup' }
  let(:uri) { "/signup" }

  context "GET /signup" do
    let(:route_method) { [:get_signin, 'GET'] }
    it_behaves_like "Lynr::Controller::Base#valid_request"
    it { expect(response_body_document).to have_element('form.signin') }

    context "with features.demo" do
      include_context "features.demo=true"
      it_behaves_like "Lynr::Controller::Base#valid_request"
      it { expect(response_body_document).to have_element('form.signin-demo') }
    end

    context "with signed-in session" do
      let(:session) {
        session = double("Rack::Session::Abstract::SessionHash")
        allow(session).to receive(:destroy) { nil }
        allow(session).to receive(:[]) { saved_empty_dealership.id.to_s }
        session
      }
      let(:env_opts) do
        { 'rack.session' => session }
      end
      it_behaves_like "Lynr::Controller::Base#valid_request", 302 do
        it { expect(response_headers).to include('Location') }
        it { expect(response_headers['Location']).to eq("/admin/#{saved_empty_dealership.id}") }
      end
    end
  end

end
