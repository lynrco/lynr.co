require 'rspec/autorun'
require 'stripe_mock'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/auth/signup'

describe Lynr::Controller::Auth::Signup do

  include_context "spec/support/ConfigHelper"
  include_context "spec/support/DemoHelper"
  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  subject(:controller) {
    Lynr::Controller::Auth::Signup.new
  }

  let(:path) { '/signup' }
  let(:uri) { "/signup" }

  before(:all) do
    stub_config('app', { 'stripe' => {
      'plan' => 'lynr_spec', 'pub_key' => 'made up' }
    })
    stub_config('features', 'demo' => 'false')
  end

  context "GET /signup" do
    let(:route_method) { [:get_signup, 'GET'] }
    it_behaves_like "Lynr::Controller::Base#valid_request"
    it { expect(response_body_document).to have_element('input[name=stripeToken]') }

    context "with features.demo" do
      include_context "features.demo=true"

      it_behaves_like "Lynr::Controller::Base#valid_request"
      it { expect(response_body_document).to_not have_element('input[name=stripeToken]') }
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

  context "POST /signup" do
    let(:card_token) { StripeMock.generate_card_token(last4: "4242", exp_year: 2016) }
    let(:route_method) { [:post_signup, 'POST'] }
    let(:posted) {
      {
        'email' => 'bryan@lynr.co',
        'password' => '1234',
        'password_confirm' => '1234',
        'agree_terms' => '1',
        'stripeToken' => card_token,
      }
    }
    let(:env_opts) { { params: posted } }
    let(:dealership) {
      location = response_headers['Location']
      dealership_id = location.match(%r(/admin/(?<id>.*)$))['id']
      controller.dealer_dao.get(dealership_id)
    }

    before(:each) do
      Stripe::Plan.create(amount: 9900, id: 'lynr_spec')
    end

    context "with valid data" do
      describe "#validate_signup" do
        it { expect(controller.validate_signup(posted)).to be_empty }
      end

      it_behaves_like "Lynr::Controller::Base#valid_request", 302 do
        it "creates dealership with active subscription" do
          expect(dealership.subscription.active?).to be_true
        end
      end
    end

    context "with missing data" do
      describe "#validate_signup" do
        ['email', 'password', 'agree_terms', 'stripeToken'].each do |field|
          it "should have error for #{field} without #{field}" do
            data = posted.delete_if { |k,v| k == field }
            errors = controller.validate_signup(data)
            expect(controller.validate_signup(data)).to include(field)
          end
        end

        it "should have error for password without password_confirm" do
          data = posted.delete_if { |k,v| k == 'password_confirm' }
          expect(controller.validate_signup(data)).to include('password')
        end
      end

      it_behaves_like "Lynr::Controller::Base#valid_request" do
        let(:posted) {
          {
            'password' => '1234',
            'password_confirm' => '1234',
            'agree_terms' => '1',
            'stripeToken' => card_token,
          }
        }
        it { expect(response_body_document).to have_element('.msg-error') }
        it "should have .msg-error 'Email is required.'" do
          expect(response_body_document.css('.msg-error').first.text).to eq('Email is required.')
        end
      end
    end

    context "with features.demo" do
      include_context "features.demo=true"

      let(:posted) { { 'email' => 'bryan@lynr.co', 'agree_terms' => '1', } }

      context "with valid data (demo)" do
        describe "#validate_signup" do
          it { expect(controller.validate_signup(posted)).to be_empty }
        end

        it_behaves_like "Lynr::Controller::Base#valid_request", 302 do
          it "creates dealership with demo subscription" do
            expect(dealership.subscription.demo?).to be_true
          end
        end
      end

      context "with missing data (demo)" do
        describe "#validate_signup" do
          ['email', 'agree_terms'].each do |field|
            it "should have error for #{field} without #{field}" do
              data = posted.delete_if { |k,v| k == field }
              expect(controller.validate_signup(data)).to include(field)
            end
          end
        end
        it_behaves_like "Lynr::Controller::Base#valid_request" do
          let(:posted) { {} }
          it { expect(response_body_document).to have_element('.msg-error') }
          it "should have .msg-error 'Email is required.'" do
            expect(response_body_document.css('.msg-error').first.text).to eq('Email is required.')
          end
        end
      end

    end
  end

  describe "#create_dealership" do
    let(:customer) {
      Stripe::Customer.create({
        email: 'bryan@lynr.co',
        card:  'void_card_token',
      })
    }
    let(:identity) {
      Lynr::Model::Identity.new('bryan@lynr.co', 'foobar')
    }

    it "should create dealership when given identity and customer" do
      dealership = controller.create_dealership(identity, customer)
      expect(dealership).to be_instance_of(Lynr::Model::Dealership)
    end

    it "should create dealership when only given identity" do
      dealership = controller.create_dealership(identity, nil)
      expect(dealership).to be_instance_of(Lynr::Model::Dealership)
    end

  end

end
