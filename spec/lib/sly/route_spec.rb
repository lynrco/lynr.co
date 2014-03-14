require 'rspec/autorun'
require './spec/spec_helper'

require './lib/sly/route'

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

      let(:route) {
        Sly::Route.new('GET', '/admin/:slug/account', lambda { |req| Rack::Response.new })
      }

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

      let(:route) {
        Sly::Route.new('GET', '/admin/:slug/:account', lambda { |req| Rack::Response.new })
      }

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

    context "ends with wildcard" do

      let(:route) { Sly::Route.new('GET', '/admin/*', lambda { |req| Rack::Response.new}) }

      it "doesn't match a URI not starting with /admin/" do
        req = MockRequest.new('GET', '/twitter/hi')
        expect(route.matches_filters?(req)).to be_false
      end

      it "matches one path part following /admin/" do
        req = MockRequest.new('GET', '/admin/hi')
        expect(route.matches_filters?(req)).to be_true
      end

      it "matches two path parts following /admin/" do
        req = MockRequest.new('GET', '/admin/hi/there')
        expect(route.matches_filters?(req)).to be_true
      end

    end

    context "contains path param, ends with wildcard" do

      let(:route) { Sly::Route.new('GET', '/admin/:slug/*', lambda { |req| Rack::Response.new}) }

      it "matches with one wildcard part in uri" do
        req = MockRequest.new('GET', '/admin/21345/account')
        expect(route.matches_filters?(req)).to be_true
      end

      it "matches with two wildcard parts in uri" do
        req = MockRequest.new('GET', '/admin/21345/account/rep')
        expect(route.matches_filters?(req)).to be_true
      end

      it "doesn't match without something in wildcard" do
        req = MockRequest.new('GET', '/admin/21345')
        expect(route.matches_filters?(req)).to be_false
      end

    end

  end

  describe "#call" do

    let(:env) { Rack::MockRequest.env_for('/admin/21345/fry') }

    it "deals with `Rack::Response` instances" do
      route = Sly::Route.new('GET', '/admin/:slug/:account', lambda { |req| Rack::Response.new })
      response = route.call(env)
      expect(response[0]).to eq(200)
    end

    it "deals with Array instances" do
      route = Sly::Route.new('GET', '/admin/:slug/:account', lambda { |req|
        Rack::Response.new.finish
      })
      response = route.call(env)
      expect(response[0]).to eq(200)
    end

    it "fails on strings" do
      route = Sly::Route.new('GET', '/admin/:slug/:account', lambda { |req| "success" })
      response = route.call(env)
      expect(response[0]).to eq(501)
    end

    it "returns _tail_ when requested" do
      route = Sly::Route.new('GET', '/admin/:slug/*', lambda { |req|
        Rack::Response.new(req['_tail_'])
      })
      response = route.call(env)
      expect(response[0]).to eq(200)
      expect(response[2].body).to eq(['fry'])
    end

    it "gets WrongRoute when filters don't match" do
      route = Sly::Route.new('GET', '/admin/:slug/:account', lambda { |req| Rack::Response.new })
      env = Rack::MockRequest.env_for('/admin/')
      response = route.call(env)
      expect(response).to eq(Sly::Route::WrongRoute)
    end

  end

  describe ".make_r" do

    it "makes a Regexp with no capture groups for /admin/hanky/account" do
      regex = Sly::Route.make_r('/admin/hanky/account')
      expect(regex.match('/admin/hanky/account').length).to eq(1)
    end

    it "makes a Regexp with single capture group for :dealership" do
      regex = Sly::Route.make_r('/admin/:dealership/account')
      m = regex.match('/admin/hanky/account')
      expect(m.length).to eq(2)
      expect(m['dealership']).to eq('hanky')
    end

  end

end
