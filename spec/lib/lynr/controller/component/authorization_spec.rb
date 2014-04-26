require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/controller/component/authorization'
require './lib/lynr/persist/dealership_dao'

describe Lynr::Controller::Authorization do

  include_context "spec/support/ModelHelper"
  include_context "spec/support/RouteHelper"

  class Dummy
    include Lynr::Controller::Authorization
    def dealer_dao
      @dealer_dao ||= Lynr::Persist::DealershipDao.new
    end
  end

  subject(:controller) { Dummy.new }

  describe "#authorized?" do
    let(:dealership) { saved_empty_dealership }
    it "should be true if dealership.id in role" do
      role = "admin:#{saved_empty_dealership.id}"
      expect(controller.authorized?(role, saved_empty_dealership)).to be_true
    end
    it "should be false if dealership.id not in role" do
      role = "admin:#{BSON::ObjectId.from_time(Time.now)}"
      expect(controller.authorized?(role, dealership)).to be_false
    end
    it "should be false if role is nil" do
      expect(controller.authorized?(nil, dealership)).to be_false
    end
    it "should be false if role is false" do
      expect(controller.authorized?(false, dealership)).to be_false
    end
  end

end
