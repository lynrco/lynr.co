require 'rspec/autorun'
require 'stripe_mock'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/auth/signup'

describe Lynr::Controller::Auth::Signup do

  include_context "spec/support/ConfigHelper"
  include_context "spec/support/RouteHelper"

  subject(:controller) { Lynr::Controller::Auth::Signup.new }

  let(:path) { '/signup' }
  let(:uri) { "/signup" }

  let(:posted) {
    {
      'email' => 'bryan@lynr.co',
      'password' => '1234',
      'password_confirm' => '1234',
      'agree_terms' => '1',
      'stripeToken' => 'foobar',
    }
  }

  before(:each) do
    stub_config('app', { 'stripe' => { 'plan' => 'lynr_spec' } })
  end

  context "POST /signup - with valid data" do
    describe "#validate_signup" do
      it { expect(controller.validate_signup(posted)).to be_empty }
    end
  end

  context "POST /signup - missing data" do
    ['email', 'password', 'agree_terms', 'stripeToken'].each do |field|
      describe "#validate_signup - without #{field}" do
        let(:posted) { super().delete_if { |k,v| k == field } }
        let(:errors) { controller.validate_signup(posted) }

        it { expect(errors).to_not be_empty }
        it { expect(errors).to include(field) }
      end
    end
  end

  context "POST /signup - missing password_confirm" do
    let(:posted) { super().delete_if { |k,v| k == 'password_confirm' } }

    describe "#validate_signup" do
      let(:errors) { controller.validate_signup(posted) }

      it { expect(errors).to_not be_empty }
      it { expect(errors).to include('password') }
    end
  end

  describe "#create_dealership" do

    before { StripeMock.start }
    after { StripeMock.stop }
    let(:customer) {
      Stripe::Customer.create({
        email: 'bryan@lynr.co',
        card:  'void_card_token',
      })
    }
    let(:identity) {
      Lynr::Model::Identity.new('bryan@lynr.co', 'foobar')
    }

    it "creates dealership when given identity and customer" do
      dealership = controller.create_dealership(identity, customer)
      expect(dealership).to be_instance_of(Lynr::Model::Dealership)
    end

    it "creates dealership when given identity only" do
      dealership = controller.create_dealership(identity, nil)
      expect(dealership).to be_instance_of(Lynr::Model::Dealership)
    end

  end

end
