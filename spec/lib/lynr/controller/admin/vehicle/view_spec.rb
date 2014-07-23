require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/vehicle/view'

describe Lynr::Controller::Admin::Vehicle::View, if: MongoHelpers.connected? do

  include_context 'spec/support/ModelHelper'
  include_context 'spec/support/RouteHelper'

  let(:path) { '/admin/:slug/:vehicle' }
  let(:uri) { "/admin/#{saved_empty_dealership.id}/#{saved_empty_vehicle.id}" }
  let(:env_opts) { { 'rack.session' => { 'dealer_id' => saved_empty_dealership.id } } }
  let(:full_uri) { "https://#{domain}#{uri}" }
  let(:route_method) { [:get_html, 'GET'] }

  context 'GET /admin/:slug/:vehicle' do
    it_behaves_like 'Lynr::Controller::Base#valid_request'
  end

  context 'GET /admin/:slug/undefined' do
    let(:uri) { "/admin/#{saved_empty_dealership.id}/undefined" }
    it 'raises a NotFoundError' do
      expect { route.call(env) }.to raise_error(Sly::NotFoundError)
    end
  end

  context 'GET /admin/:slug/<non-existant>' do
    let(:uri) { "/admin/#{saved_empty_dealership.id}/#{BSON::ObjectId.from_time(Time.now)}" }
    it 'raises a NotFoundError' do
      expect { route.call(env) }.to raise_error(Sly::NotFoundError)
    end
  end

end
