require 'rspec/autorun'
require 'stripe_mock'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/auth/signin'

describe Lynr::Controller::Auth::Signin do

  include_context 'spec/support/ConfigHelper'
  include_context 'spec/support/DemoHelper'
  include_context 'spec/support/ModelHelper'
  include_context 'spec/support/RouteHelper'
  include_context 'spec/support/TokenHelper'

  subject(:controller) {
    Lynr::Controller::Auth::Signin.new
  }

  let(:path) { '/signin' }
  let(:uri) { '/signin' }

  context 'GET /signin' do
    let(:route_method) { [:get_signin, 'GET'] }
    it_behaves_like 'Lynr::Controller::Base#valid_request'
    it { expect(response_body_document).to have_element('form.signin') }

    context 'with features.demo' do
      include_context 'features.demo=true'
      it_behaves_like 'Lynr::Controller::Base#valid_request'
      it { expect(response_body_document).to have_element('form.signup-demo') }
    end

    context 'with signed-in session' do
      let(:session) {
        session = double('Rack::Session::Abstract::SessionHash')
        allow(session).to receive(:destroy) { nil }
        allow(session).to receive(:[]) { saved_empty_dealership.id.to_s }
        session
      }
      let(:env_opts) do
        { 'rack.session' => session }
      end
      it_behaves_like 'Lynr::Controller::Base#valid_request', 302 do
        it { expect(response_headers).to include('Location') }
        it { expect(response_headers['Location']).to eq("/admin/#{saved_empty_dealership.id}") }
      end
    end
  end

  context 'GET /signin/:token' do
    let(:path) { '/signin/:token' }
    let(:uri) { "/signin/#{request_token.id}" }
    let(:route_method) { [:get_token_signin, 'GET'] }

    context 'with valid token' do
      let(:request_token) { token('dealership' => saved_empty_dealership) }
      it_behaves_like 'Lynr::Controller::Base#valid_request', 302
      it 'redirects to password reset' do
        redirect_uri = "/admin/#{saved_empty_dealership.id}/account/password"
        expect(response_headers['Location']).to eq(redirect_uri)
      end
    end
    context 'with expired token' do
      let(:request_token) do
        token('dealership' => saved_empty_dealership, 'expires' => (Time.now - 1))
      end
      it_behaves_like 'Lynr::Controller::Base#valid_request'
      it { expect(response_body_document).to have_element('.msg-error') }
      it 'should have expired error message' do
        message = 'Sorry, this signin URL has expired.'
        expect(response_body_document.css('.msg-error').first.text).to eq(message)
      end
    end
    context 'with no token found' do
      let(:request_token) do
        OpenStruct.new(id: BSON::ObjectId.from_time(Time.now))
      end
      it_behaves_like 'Lynr::Controller::Base#valid_request'
      it { expect(response_body_document).to have_element('.msg-error') }
      it 'should have expired error message' do
        message = "Sorry, the token in the URL doesn't match our records."
        expect(response_body_document.css('.msg-error').first.text).to eq(message)
      end
    end
  end

  context 'POST /signin' do
    let(:route_method) { [:post_signin, 'POST'] }
    let(:posted) do
      { 'email' => saved_empty_dealership.identity.email, 'password' => 'this is a fake password', }
    end
    let(:env_opts) do { params: posted } end

    let(:response_dealership) {
      location = response_headers['Location']
      dealership_id = location.match(%r(/admin/(?<id>.*)$))['id']
      controller.dealer_dao.get(dealership_id)
    }

    context 'with valid credentials' do
      it_behaves_like 'Lynr::Controller::Base#valid_request', 302 do
        it 'creates dealership with active subscription' do
          expect(response_dealership.identity.email).to eq(posted['email'])
        end
      end
    end

    context 'with incorrect password' do
      let(:posted) do super().merge({ 'password' => 'invalid password' }) end
      it_behaves_like 'Lynr::Controller::Base#valid_request' do
        it { expect(response_body_document).to have_element('form.signin') }
        it { expect(response_body_document).to_not have_element('form.signup-demo') }
      end
    end

    context 'with features.demo' do
      include_context 'features.demo=true'
      let(:posted) do { 'email' => saved_demo_dealership.identity.email } end
      it_behaves_like 'Lynr::Controller::Base#valid_request', 302 do
        it 'creates dealership with active subscription' do
          expect(response_dealership.identity.email).to eq(posted['email'])
        end
      end

      context 'with email of non-demo account' do
        let(:posted) do { 'email' => saved_empty_dealership.identity.email } end
        it_behaves_like 'Lynr::Controller::Base#valid_request' do
          it { expect(response_body_document).to have_element('form.signup-demo') }
        end
      end
    end
  end

end
