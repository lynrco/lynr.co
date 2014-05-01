require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/vin'

describe Lynr::Controller::AdminVin, if: MongoHelpers.connected? do

  include_context 'spec/support/ModelHelper'
  include_context 'spec/support/RouteHelper'

  let(:path) { '/admin/:slug/vin/search' }
  let(:uri) { "/admin/#{saved_empty_dealership.id}/vin/search" }
  let(:env_opts) { { 'rack.session' => { 'dealer_id' => saved_empty_dealership.id } } }
  let(:full_uri) { "https://#{domain}#{uri}" }

  before(:each) do
    DataOne::Api.any_instance.stub(:fetch_dataone) do |vin|
      File.read('spec/data/1HGEJ6229XL063838.xml').gsub('1HGEJ6229XL063838', vin)
    end
  end

  context 'POST /admin/:slug/vin/search' do

    let(:route_method) { [:search, 'POST'] }
    let(:env_opts) {
      {
        method: route_method[1],
        params: { 'vin' => '1HGEJ6229XL063838' },
        'rack.session' => { 'dealer_id' => saved_empty_dealership.id },
      }
    }

    it_behaves_like 'Lynr::Controller::Base#valid_request', 302
    it { expect(response_headers['Location']).to match(%r(/admin/#{saved_empty_dealership.id}/[^/]*/edit)) }

  end

end
