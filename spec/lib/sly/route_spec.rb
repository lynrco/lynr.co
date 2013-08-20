require 'rspec/autorun'
require './spec/spec_helper'

require 'sly/route'

class MockRequest
  attr_accessor :request_method, :path
  def initialize(verb, path)
    @request_method = verb.upcase
    @path = path
  end
end

describe Sly::Route do

  describe "#matches_filters?" do

    context "simple path (no path params)" do

      let(:route) { Sly::Route.new('GET', '/admin', lambda { |req| Rack::Response.new }) }

      it "matches an exact uri" do
        req = MockRequest.new('GET', '/admin')
        expect(route.matches_filters?(req)).to be_true
      end

      it "doesn't match with trailing slash" do
        req = MockRequest.new('GET', '/admin/')
        expect(route.matches_filters?(req)).to be_false
      end

      it "doesn't match with something preceding" do
        req = MockRequest.new('GET', '/hi/admin')
        expect(route.matches_filters?(req)).to be_false
      end

    end

    context "ends with path param" do

      let(:route) { Sly::Route.new('GET', '/admin/:slug', lambda { |req| Rack::Response.new }) }

      it "matches an exact uri" do
        req = MockRequest.new('GET', '/admin/21345')
        expect(route.matches_filters?(req)).to be_true
      end

      it "doesn't match with trailing slash" do
        req = MockRequest.new('GET', '/admin/21345/')
        expect(route.matches_filters?(req)).to be_false
      end

      it "doesn't match with something preceding" do
        req = MockRequest.new('GET', '/howdy/admin/21345/')
        expect(route.matches_filters?(req)).to be_false
      end

      it "doesn't match with an extra part" do
        req = MockRequest.new('GET', '/admin/21345/howdy')
        expect(route.matches_filters?(req)).to be_false
      end

    end

    context "path param followed by fixed string" do

      let(:route) { Sly::Route.new('GET', '/admin/:slug/account', lambda { |req| Rack::Response.new }) }

      it "matches an exact uri" do
        req = MockRequest.new('GET', '/admin/21345/account')
        expect(route.matches_filters?(req)).to be_true
      end

      it "doesn't match without the fixed string" do
        req = MockRequest.new('GET', '/admin/21345')
        expect(route.matches_filters?(req)).to be_false
      end

      it "doesn't match with only part of the fixed string" do
        req = MockRequest.new('GET', '/admin/21345/acc')
        expect(route.matches_filters?(req)).to be_false
      end

      it "doesn't match with trailing slash" do
        req = MockRequest.new('GET', '/admin/21345/account/')
        expect(route.matches_filters?(req)).to be_false
      end

      it "doesn't match with something preceding the path" do
        req = MockRequest.new('GET', '/howdy/admin/21345/account')
        expect(route.matches_filters?(req)).to be_false
      end

      it "doesn't match with something following the fixed string" do
        req = MockRequest.new('GET', '/admin/21345/account/hi')
        expect(route.matches_filters?(req)).to be_false
      end

    end

    context "multiple path params" do

      let(:route) { Sly::Route.new('GET', '/admin/:slug/:account', lambda { |req| Rack::Response.new }) }

      it "matches an exact uri" do
        req = MockRequest.new('GET', '/admin/21345/fry')
        expect(route.matches_filters?(req)).to be_true
      end

      it "doesn't match with trailing slash" do
        req = MockRequest.new('GET', '/admin/21345/blah/')
        expect(route.matches_filters?(req)).to be_false
      end

      it "doesn't match with something preceding" do
        req = MockRequest.new('GET', '/foo/admin/21345/')
        expect(route.matches_filters?(req)).to be_false
      end

      it "doesn't match with an extra part" do
        req = MockRequest.new('GET', '/admin/21345/howdy/bar')
        expect(route.matches_filters?(req)).to be_false
      end

    end

  end

  describe "#handle" do

    let(:request) { Rack::MockRequest.env_for('/admin/21345/fry') }

    it "deals with `Rack::Response` instances" do
      route = Sly::Route.new('GET', '/admin/:slug/:account', lambda { |req| Rack::Response.new })
      response = route.call(request)
      expect(response[0]).to eq(200)
    end

    it "deals with Array instances" do
      route = Sly::Route.new('GET', '/admin/:slug/:account', lambda { |req| Rack::Response.new.finish })
      response = route.call(request)
      expect(response[0]).to eq(200)
    end

    it "fails on strings" do
      route = Sly::Route.new('GET', '/admin/:slug/:account', lambda { |req| "success" })
      response = route.call(request)
      expect(response[0]).to eq(501)
    end

  end

end
