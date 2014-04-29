require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/auth/forgot'

describe Lynr::Controller::Auth::Forgot, :if => (MongoHelpers.connected?) do

  include_context 'spec/support/ConfigHelper'
  include_context 'spec/support/DemoHelper'
  include_context 'spec/support/ModelHelper'
  include_context 'spec/support/RouteHelper'
  include_context 'spec/support/TokenHelper'

  subject(:controller) { Lynr::Controller::Auth::Forgot.new }
  let(:path) { '/signin/forgot' }
  let(:uri) { '/signin/forgot' }

  context 'GET /signin/forgot' do
    let(:form) { response_body_document.css('form.signin').first }
    it 'response.status should eq 200' do expect(response_status).to eq(200) end
    it { expect(response_body_document).to have_element('form.signin') }
    it { expect(form['method']).to eq('POST') }
    it { expect(form['action']).to eq('/signin/forgot') }
  end

  context 'POST /signin/forgot' do
    let(:route_method) { [:post, 'POST'] }
    let(:posted) do
      { 'email' => saved_empty_dealership.identity.email, }
    end
    let(:env_opts) do { params: posted } end
    it 'response.status should eq 200' do expect(response_status).to eq(200) end
    it { expect(response_body_document).to have_element('form.signin') }
    it { expect(response_body_document).to have_element('.msg') }
    it { expect(response_body_document).to_not have_element('.msg-error') }
    it { expect(response_body_document.css('.msg').first.text).to match(/^Reset notification sent/) }
  end

end
