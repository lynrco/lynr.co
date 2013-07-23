require 'rspec/autorun'
require './spec/spec_helper'

require 'sly/route'
require 'sly/router'

describe Sly::Router do

  describe "#call" do

    let(:router) { Sly::Router.new([]) }
    let(:admin) {
      Sly::Route.new('GET', '/admin', lambda { |req| Rack::Response.new('/admin') })
    }
    let(:account) {
      Sly::Route.new('GET', '/admin/account', lambda { |req| Rack::Response.new('/admin/account') })
    }
    let(:wildcard) {
      Sly::Route.new('GET', '/admin/:id', lambda { |req| Rack::Response.new('/admin/:id') })
    }

    context "No routes" do

      it "returns 404 response for any path" do
        res = router.call(Rack::MockRequest.env_for('/admin'))
        expect(res[0]).to eq(404)
      end

    end

    context "Single /admin route" do

      before(:each) { router.add(admin) }

      it "has one matching route gives 200 for /admin" do
        res = router.call(Rack::MockRequest.env_for('/admin'))
        expect(res[0]).to eq(200)
        expect(res[2].body).to start_with(['/admin'])
      end

    end

    context "One /admin route, One /admin/* route" do

      before(:each) {
        router.add(admin)
        router.add(account)
      }

      it "has one matching route gives 200 for /admin" do
        res = router.call(Rack::MockRequest.env_for('/admin'))
        expect(res[0]).to eq(200)
        expect(res[2].body).to start_with(['/admin'])
      end

      it "has one matching route gives 200 for /admin/account" do
        res = router.call(Rack::MockRequest.env_for('/admin/account'))
        expect(res[0]).to eq(200)
        expect(res[2].body).to start_with(['/admin/account'])
      end

    end

    context "One /admin route, Two /admin/* route" do

      before(:each) {
        router.add(admin)
        router.add(account)
        router.add(wildcard)
      }

      it "one matching route gives 200 for /admin" do
        res = router.call(Rack::MockRequest.env_for('/admin'))
        expect(res[0]).to eq(200)
        expect(res[2].body).to start_with(['/admin'])
      end

      it "has one matching route gives 200 for /admin/account" do
        res = router.call(Rack::MockRequest.env_for('/admin/account'))
        expect(res[0]).to eq(200)
        expect(res[2].body).to start_with(['/admin/account'])
      end

      it "requests for /admin/* (not /admin/account) give 200" do
        res = router.call(Rack::MockRequest.env_for('/admin/1738901'))
        expect(res[0]).to eq(200)
        expect(res[2].body).to start_with(['/admin/:id'])
      end

    end

    context "Two /admin routes" do

      before(:each) {
        router.add(admin)
        router.add(Sly::Route.new('GET', '/admin', lambda { |req| Rack::Response.new('/admin2') }))
      }

      it "gives 501 error for /admin" do
        res = router.call(Rack::MockRequest.env_for('/admin'))
        expect(res[0]).to eq(501)
        expect(res[2]).to start_with(['Too many matching routes.'])
      end

    end

  end

end
