require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/account'

describe Lynr::Controller::AdminAccount do

  include_context "spec/support/ConfigHelper"
  include_context "spec/support/DemoHelper"
  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  let(:session_user) { saved_empty_dealership }
  let(:path) { '/admin/:slug/account' }
  let(:uri) { "/admin/#{session_user.id}/account" }
  let(:env_opts) { { 'rack.session' => { 'dealer_id' => session_user.id } } }

  context "GET /admin/:slug/account" do
    let(:route_method) { [:get_account, 'GET'] }
    it_behaves_like "Lynr::Controller::Base#valid_request" do
      it { expect(response_body_document).to have_element('p.account-link') }
      it "should have .account-link with 'Upgrade Account'" do
        expect(response_body_document.css('.account-link a').first.text).to eq('Change Password')
      end
    end

    context "with features.demo" do
      let(:session_user) { saved_demo_dealership }
      include_context "features.demo=true"
      it_behaves_like "Lynr::Controller::Base#valid_request" do
        it { expect(response_body_document).to have_element('p.account-link') }
        it "should have .account-link with 'Upgrade Account'" do
          expect(response_body_document.css('.account-link a').first.text).to eq('Upgrade Account')
        end
      end
    end
  end

  context "POST /admin/:slug/account" do
    let(:route_method) { [:post_account, 'POST'] }
    let(:posted) do { 'email' => 'bryan+account_spec@lynr.co', } end
    let(:env_opts) do super().merge({ params: posted }) end
    it_behaves_like "Lynr::Controller::Base#valid_request", 302

    context "with features.demo" do
      let(:session_user) { saved_demo_dealership }
      include_context "features.demo=true"
      it_behaves_like "Lynr::Controller::Base#valid_request", 302
    end
  end

end
