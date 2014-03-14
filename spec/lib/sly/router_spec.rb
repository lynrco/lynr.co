require 'rspec/autorun'
require './spec/spec_helper'

require './lib/sly/route'
require './lib/sly/router'

describe Sly::Router do

  let(:router) { Sly::Router.new([]) }
  let(:admin) {
    Sly::Route.new('GET', '/admin', lambda { |req| Rack::Response.new('/admin') })
  }
  let(:account) {
    Sly::Route.new('GET', '/admin/account', lambda { |req| Rack::Response.new('/admin/account') })
  }
  let(:admin_by_id) {
    Sly::Route.new('GET', '/admin/:id', lambda { |req| Rack::Response.new('/admin/:id') })
  }

  describe "#call" do

    context "No routes" do

      it "returns 404 response for any path" do
        expect {
          router.call(Rack::MockRequest.env_for('/admin'))
        }.to raise_error(Sly::NotFoundError, "No matching routes.")
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
        router.add(admin_by_id)
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
        expect {
          router.call(Rack::MockRequest.env_for('/admin'))
        }.to raise_error(Sly::TooManyRoutesError)
      end

    end

  end

  describe "#include?" do

    it "is false when no routes added" do
      expect(router.include?(admin.to_s)).to be_false
    end

    it "is false when queried for `Route` hasn't been added" do
      router.add(admin)
      expect(router.include?(admin_by_id.to_s)).to be_false
    end

    it "is true when queried for `Route` has been added" do
      router.add(admin)
      expect(router.include?(admin.to_s)).to be_true
    end

  end

  describe "#sort_by_path_params" do

    it "returns empty array when given empty array" do
      expect(router.sort_by_path_params([])).to eq([])
    end

    it "returns array with one route when given single element" do
      expect(router.sort_by_path_params([admin])).to eq([admin])
    end

    it "sorts route with no path parameters first" do
      expect(router.sort_by_path_params([admin_by_id, account])).to eq([account, admin_by_id])
    end

    it "raises error when both routes given have no path parameters" do
      expect { router.sort_by_path_params([admin, account]) }.to raise_error(Sly::TooManyRoutesError)
    end

  end

end
