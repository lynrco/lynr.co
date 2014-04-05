require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/controller/component/paginated'

describe Lynr::Controller::Paginated do

  include_context "spec/support/RouteHelper"

  class Dummy
    include Lynr::Controller::Paginated
  end

  subject(:controller) do
    Dummy.new
  end
  let(:path) { '/admin/:slug' }

  describe "#page" do

    it "is a number" do
      expect(controller.page(request('/admin/bimac-honda-la'))).to be_instance_of(Fixnum)
    end

    it "defaults to 1" do
      expect(controller.page(request('/admin/bimac-honda-la'))).to eq(1)
    end

    it "is the value of the ?page= parameter" do
      expect(controller.page(request('/admin/bimac-honda-la?page=2'))).to eq(2)
    end

  end

  # NOTE: These aren't specs so much as alerts that this changed (if it does)
  describe "::PER_PAGE" do

    it "exists" do
      expect(Lynr::Controller::Paginated::PER_PAGE).to be
    end

    it "is 10" do
      expect(Lynr::Controller::Paginated::PER_PAGE).to eq(10)
    end

  end

end
