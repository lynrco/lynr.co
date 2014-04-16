require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require 'nokogiri'

require './lib/lynr/controller/home'

describe Lynr::Controller::Home do

  include_context "spec/support/ConfigHelper"
  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  let(:path) { '/' }
  let(:uri) { "/" }

  before(:each) do
    stub_config('app', { 'librato' => { } })
    stub_config('features', { 'demo' => false, 'live' => true })
  end

  context "GET /" do

    let(:route_method) { [:index, 'GET'] }

    it_behaves_like "Lynr::Controller::Base#valid_request"

    it { expect(response_headers).to include('Content-Type') }

    it { expect(response_headers['Content-Type']).to match(/text\/html/) }

    context "without features.demo" do

      it { expect(response_body_document.css('form.signup')).to be_empty }

    end

    context "with features.demo" do

      before(:each) do
        stub_config('features', { 'demo' => true, 'live' => false })
      end

      it "has a signup form" do
        expect(response_body_document.css('form.signup')).to_not be_empty
      end

    end

  end

end
