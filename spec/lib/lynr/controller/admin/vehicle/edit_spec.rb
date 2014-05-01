require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/vehicle/edit'

describe Lynr::Controller::Admin::Vehicle::Edit, if: MongoHelpers.connected? do

  include_context 'spec/support/ModelHelper'
  include_context 'spec/support/RouteHelper'

  let(:path) { '/admin/:slug/:vehicle/edit' }
  let(:uri) { "/admin/#{saved_empty_dealership.id}/#{saved_empty_vehicle.id}/edit" }
  let(:env_opts) { { 'rack.session' => { 'dealer_id' => saved_empty_dealership.id } } }
  let(:full_uri) { "https://#{domain}#{uri}" }

  context 'GET /admin/:slug/:vehicle/edit' do

    let(:route_method) { [:get_edit_vehicle, 'GET'] }

    it_behaves_like 'Lynr::Controller::Base#valid_request'
    it { expect(response_body_document).to have_element('div.vehicle-photos') }
    it { expect(response_body_document).to have_element('form.vehicle-edit') }

  end

  context 'POST /admin/:slug/:vehicle/edit' do

    let(:route_method) { [:post_edit_vehicle, 'POST'] }
    let(:env_opts) {
      super().merge(params: { 'vin[ext_color]' => 'silver' })
    }

    it_behaves_like 'Lynr::Controller::Base#valid_request', 302
    it { expect(response_headers['Location']).to match(%r(/admin/#{saved_empty_dealership.id}/[^/]*/edit)) }

  end

end
