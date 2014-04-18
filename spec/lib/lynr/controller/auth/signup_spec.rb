require 'rspec/autorun'
require 'stripe_mock'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/auth/signup'

describe Lynr::Controller::Auth::Signup do

  include_context "spec/support/ConfigHelper"
  include_context "spec/support/RouteHelper"

  subject(:controller) {
    Lynr::Controller::Auth::Signup.new
  }

  let(:path) { '/signup' }
  let(:uri) { "/signup" }

  before(:each) { StripeMock.start }
  after(:each) { StripeMock.stop }
  before(:all) do
    stub_config('app', { 'stripe' => {
      'plan' => 'lynr_spec', 'pub_key' => 'made up' }
    })
    stub_config('features', 'demo' => 'false')
  end

  shared_context "features.demo=true" do
    before(:all) do
      stub_config('features', 'demo' => 'true')
    end
    after(:all) do
      stub_config('features', 'demo' => 'false')
    end
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

    before(:each) do
      Stripe::Plan.create(amount: 9900, id: 'lynr_spec')
    end

    context "with valid data" do
      describe "#validate_signup" do
        it { expect(controller.validate_signup(posted)).to be_empty }
      end

      it_behaves_like "Lynr::Controller::Base#valid_request", 302
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

      let(:posted) { { 'email' => 'bryan@lynr.co' } }

      context "with valid data (demo)" do
        describe "#validate_signup" do
          it { expect(controller.validate_signup(posted)).to be_empty }
        end

        it_behaves_like "Lynr::Controller::Base#valid_request", 302
      end

      context "with missing data (demo)" do
        describe "#validate_signup" do
          it "should have error for email without email" do
            data = posted.delete_if { |k,v| k == 'email' }
            expect(controller.validate_signup(data)).to include('email')
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
