require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/controller/component/authentication'
require './lib/lynr/persist/dealership_dao'

describe Lynr::Controller::Authentication do

  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  class Dummy
    include Lynr::Controller::Authentication
    def dealer_dao
      @dealer_dao ||= Lynr::Persist::DealershipDao.new
    end
  end

  subject(:controller) { Dummy.new }
  let(:path) { '/signin' }

  describe "#authenticated?" do
    let(:env_opts) do
      { 'rack.session' => session }
    end
    context "with dealer_id in session" do
      let(:session) do { 'dealer_id' => saved_empty_dealership.id.to_s } end
      it "should be true" do
        expect(controller.authenticated?(request('/signin'))).to be_true
      end
    end
    context "without dealer_id in session" do
      let(:session) do { } end
      it "should be falsedealer_id'" do
        expect(controller.authenticated?(request('/signin'))).to be_false
      end
    end
    context "without session" do
      let(:session) do nil end
      it "should be false when session is nil" do
        expect(controller.authenticated?(request('/signin'))).to be_false
      end
    end
  end

  describe "#authenticates?" do
    context "without account" do
      it { expect(controller.authenticates?('bryan@lynr.co', 'foo')).to be_false }
    end
    context "with account" do
      before(:each) do
        @dealer = saved_empty_dealership
      end
      it "should be false with wrong password" do
        expect(controller.authenticates?('bryan@lynr.co', 'foo')).to be_false
      end
      it "should be true with correct password" do
        expect(controller.authenticates?('bryan@lynr.co', 'this is a fake password')).to be_true
      end
    end
  end

  describe "#account_exists?" do
    context "without account" do
      it { expect(controller.account_exists?('bryan@lynr.co')).to be_false }
    end
    context "with account" do
      before(:each) do
        @dealer = saved_empty_dealership
      end
      it "should be true for correct email" do
        expect(controller.account_exists?('bryan@lynr.co')).to be_true
      end
      it "should be false for incorrect email" do
        expect(controller.account_exists?('bryan+ic@lynr.co')).to be_false
      end
    end
  end

end
