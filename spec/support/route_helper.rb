require 'nokogiri'
require 'rack'

require './lib/sly/request'

require './lib/lynr/controller/base'

shared_context "spec/support/RouteHelper" do

  let(:domain) { 'lynr.co.local' }
  let(:route_method) { [:get, 'GET'] }
  let(:route) { subject.class.create_route(path, *route_method) }
  let(:env_opts) { { method: route_method[1] } }
  let(:env) { env_for(uri) }
  let(:req) { Sly::Request.new(env, route.path_regex) }
  let(:response) { route.call(env) }
  let(:response_headers) { response[1] }
  let(:response_body) {
    response[2].body.reduce("") { |m,d| m + d }
  }
  let(:response_body_document) {
    require 'nokogiri'
    Nokogiri::HTML::Document.parse(response_body)
  }

  def env_for(uri)
    Rack::MockRequest.env_for("https://#{domain}#{uri}", env_opts)
  end

  def request(uri)
    Sly::Request.new(env_for(uri), Sly::Route.make_r(path))
  end

end
