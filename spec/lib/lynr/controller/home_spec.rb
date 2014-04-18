require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/home'

describe Lynr::Controller::Home do

  include_context "spec/support/ConfigHelper"
  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  let(:path) { '/' }
  let(:uri) { "/" }

  before(:each) do
    stub_config('app', { 'librato' => { } })
    stub_config('features', { 'demo' => false })
  end

  context "GET /" do

    let(:route_method) { [:index, 'GET'] }

    it_behaves_like "Lynr::Controller::Base#valid_request"

    it { expect(response_headers).to include('Content-Type') }

    it { expect(response_headers['Content-Type']).to match(/text\/html/) }

    context "without features.demo" do

      it { expect(response_body_document).to_not have_element('form.signup-demo') }

    end

    context "with features.demo" do

      before(:each) do
        stub_config('features', { 'demo' => true })
      end

      it "has a signup form" do
        expect(response_body_document).to have_element('form.signup-demo')
      end

    end

  end

end
