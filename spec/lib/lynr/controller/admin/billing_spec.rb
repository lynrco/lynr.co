require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/billing'

describe Lynr::Controller::AdminBilling do

  include_context "spec/support/ConfigHelper"
  include_context "spec/support/DemoHelper"
  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  let(:path) { '/admin/:slug/billing' }
  let(:uri) { "/admin/#{saved_empty_dealership.id}/billing" }
  let(:env_opts) { { 'rack.session' => { 'dealer_id' => saved_empty_dealership.id } } }

  before(:all) do
    stub_config('app', { 'stripe' => {
      'plan' => 'lynr_spec', 'pub_key' => 'made up' }
    })
  end

  context "GET /admin/:slug/billing" do
    let(:route_method) { [:get_billing, 'GET'] }
    it_behaves_like "Lynr::Controller::Base#valid_request" do
      it { expect(response_body_document).to have_element('form.m-billing') }
    end

    context "with features.demo" do
      include_context "features.demo=true"
      it_behaves_like "Lynr::Controller::Base#valid_request" do
        it { expect(response_body_document).to_not have_element('form.m-billing') }
      end
    end
  end

  context "POST /admin/:slug/billing" do
    let(:card_token) { StripeMock.generate_card_token(last4: "1818", exp_year: 2016) }
    let(:route_method) { [:post_billing, 'POST'] }
    let(:posted) do { 'stripeToken' => card_token, } end
    let(:env_opts) do super().merge({ params: posted }) end
    it_behaves_like "Lynr::Controller::Base#valid_request", 302

    context "with features.demo" do
      include_context "features.demo=true"
      before(:each) do
        Stripe::Plan.create(amount: 9900, id: 'lynr_spec')
      end
      it_behaves_like "Lynr::Controller::Base#valid_request", 302
    end
  end

end
