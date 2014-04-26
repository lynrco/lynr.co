require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/billing'

describe Lynr::Controller::AdminBilling do

  include_context "spec/support/ConfigHelper"
  include_context "spec/support/DemoHelper"
  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  let(:session_user) { saved_empty_dealership }
  let(:path) { '/admin/:slug/billing' }
  let(:uri) { "/admin/#{session_user.id}/billing" }
  let(:env_opts) { { 'rack.session' => { 'dealer_id' => session_user.id } } }

  before(:all) do
    stub_config('app', { 'stripe' => {
      'plan' => 'lynr_spec', 'pub_key' => 'made up' }
    })
  end

  context "GET /admin/:slug/billing" do
    let(:route_method) { [:get_billing, 'GET'] }
    it_behaves_like "Lynr::Controller::Base#valid_request" do
      it { expect(response_body_document).to have_element('form.m-billing') }
      it { expect(response_body_document).to_not have_element('form.m-billing-demo') }
    end

    context "with features.demo" do
      let(:session_user) { saved_demo_dealership }
      include_context "features.demo=true"
      it_behaves_like "Lynr::Controller::Base#valid_request" do
        it { expect(response_body_document).to have_element('form.m-billing-demo') }
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
      let(:session_user) { saved_demo_dealership }
      let(:posted) do
        super().merge({
          'password' => 'fake password', 'password_confirm' => 'fake password',
        })
      end
      include_context "features.demo=true"
      before(:each) do
        Stripe::Plan.create(amount: 9900, id: 'lynr_spec')
      end
      it_behaves_like "Lynr::Controller::Base#valid_request", 302 do
        it { expect(response_headers['Location']).to match(%r(www\.lynr\.co)) }
        it { expect(response_headers['Set-Cookie']).to match(%r(domain=www\.lynr\.co)) }
      end

      context "without matching password" do
        let(:posted) do
          super().merge({ 'password_confirm' => 'fake_password' })
        end
        it_behaves_like "Lynr::Controller::Base#valid_request" do
          it { expect(response_body_document).to have_element('div#messages') }
          it { expect(response_body_document).to have_element('.msg-error') }
          it "should have .msg-error 'Your passwords don't match.'" do
            expect(response_body_document.css('.msg-error').first.text).to eq("Your passwords don't match.")
          end
        end
      end

      context "with card error" do
        before(:each) do
          StripeMock.prepare_card_error(:invalid_number, :new_customer)
        end
        it { expect(response_body_document).to have_element('.msg-error') }
        it "should have .msg-error 'The card number is not a valid credit card number'" do
          expect(response_body_document.css('.msg-error').first.text).to eq("The card number is not a valid credit card number")
        end
      end
    end
  end

end
