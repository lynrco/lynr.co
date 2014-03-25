require 'rack'

require './lib/sly/request'

require './lib/lynr/controller/base'

shared_context "spec/support/RouteHelper" do

  let(:domain) { 'lynr.co.local' }
  let(:route_method) { [:get, 'GET'] }
  let(:route) { subject.class.create_route(path, *route_method) }
  let(:env_opts) { { method: route_method[1] } }
  let(:env) { Rack::MockRequest.env_for("https://#{domain}#{uri}", env_opts) }
  let(:req) { Sly::Request.new(env, route.path_regex) }

end
