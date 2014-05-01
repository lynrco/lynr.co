require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/vehicle/add'

describe Lynr::Controller::Admin::Vehicle::Add, if: MongoHelpers.connected? do

  include_context 'spec/support/ModelHelper'
  include_context 'spec/support/RouteHelper'

  let(:path) { '/admin/:slug/vehicle/add' }
  let(:uri) { "/admin/#{saved_empty_dealership.id}/vehicle/add" }
  let(:env_opts) { { 'rack.session' => { 'dealer_id' => saved_empty_dealership.id } } }
  let(:full_uri) { "https://#{domain}#{uri}" }

  before(:each) do
    Lynr::Queue::JobQueue.any_instance.stub(:publish) do |job, opts|
      self
    end
  end

  context 'GET /admin/:slug/vehicle/add' do

    let(:route_method) { [:get_html, 'GET'] }

    it_behaves_like 'Lynr::Controller::Base#valid_request'
    it { expect(response_body_document).to have_element('form.f-vin') }
    it { expect(response_body_document).to have_element('form.vehicle-add') }

  end

  context 'POST /admin/:slug/:vehicle/edit' do

    let(:route_method) { [:post_html, 'POST'] }
    let(:env_opts) {
      {
        method: route_method[1],
        params: { 'make' => 'Honda', 'vin[ext_color]' => 'silver' },
        'rack.session' => { 'dealer_id' => saved_empty_dealership.id },
      }
    }

    it_behaves_like 'Lynr::Controller::Base#valid_request', 302
    it { expect(response_headers['Location']).to match(%r(/admin/#{saved_empty_dealership.id}/[^/]*/edit)) }

  end

end
