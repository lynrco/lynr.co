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
  let(:uri) { '/admin/bimac-honda-la' }
  let(:req) { request(uri) }

  describe "#last_page" do

    context "with 0 elements" do
      it "is 0" do
        expect(controller.last_page(0)).to eq(0)
      end
    end

    context "with less than 10 elements" do
      (1..9).each do |num_items|
        it "is 1 for #{num_items}" do
          expect(controller.last_page(num_items)).to eq(1)
        end
      end
    end

    context "with 20 elements" do
      it "is 2" do
        expect(controller.last_page(20)).to eq(2)
      end
    end

  end

  describe "#page" do

    it "is a number" do
      expect(controller.page(req)).to be_instance_of(Fixnum)
    end

    it "defaults to 1" do
      expect(controller.page(req)).to eq(1)
    end

    context "with page parameter" do

      let(:uri) { '/admin/bimac-honda-la?page=2' }

      it "is the value of the ?page= parameter" do
        expect(controller.page(req)).to eq(2)
      end

    end

  end

  describe "#page_nums" do

    context "with up to 10 items" do
      it "is a single element array" do
        expect(controller.page_nums(req, 10).to_a.length).to eq(1)
      end
    end

    context "with 20 items" do
      it "is a two element array" do
        expect(controller.page_nums(req, 20).to_a.length).to eq(2)
      end
      it "covers 1 and 2" do
        expect(controller.page_nums(req, 20)).to cover(1, 2)
      end
    end

    context "with 100 items" do

      it "is a five element array" do
        expect(controller.page_nums(req, 100).to_a.length).to eq(5)
      end
      it "covers 1-5" do
        expect(controller.page_nums(req, 100)).to cover(1, 2, 3, 4, 5)
      end
      it "doesn't cover 6-10" do
        expect(controller.page_nums(req, 100)).to_not cover(6, 7, 8, 9, 10)
      end

      context "with page=2" do
        let(:uri) { '/admin/bimac-honda-la?page=2' }
        it "covers 1-5" do
          expect(controller.page_nums(req, 100)).to cover(1, 2, 3, 4, 5)
        end
      end

      context "with page=3" do
        let(:uri) { '/admin/bimac-honda-la?page=3' }
        it "covers 1-5" do
          expect(controller.page_nums(req, 100)).to cover(1, 2, 3, 4, 5)
        end
      end

      context "with page=4" do
        let(:uri) { '/admin/bimac-honda-la?page=4' }
        it "covers 2-6" do
          expect(controller.page_nums(req, 100)).to cover(2, 3, 4, 5, 6)
        end
      end

      context "with page=5" do
        let(:uri) { '/admin/bimac-honda-la?page=5' }
        it "covers 3-7" do
          expect(controller.page_nums(req, 100)).to cover(3, 4, 5, 6, 7)
        end
      end

      context "with page=6" do
        let(:uri) { '/admin/bimac-honda-la?page=6' }
        it "covers 4-8" do
          expect(controller.page_nums(req, 100)).to cover(4, 5, 6, 7, 8)
        end
      end

      context "with page=7" do
        let(:uri) { '/admin/bimac-honda-la?page=7' }
        it "covers 5-9" do
          expect(controller.page_nums(req, 100)).to cover(5, 6, 7, 8, 9)
        end
      end

      context "with page=8" do
        let(:uri) { '/admin/bimac-honda-la?page=8' }
        it "covers 6-10" do
          expect(controller.page_nums(req, 100)).to cover(6, 7, 8, 9, 10)
        end
      end

      context "with page=9" do
        let(:uri) { '/admin/bimac-honda-la?page=9' }
        it "covers 6-10" do
          expect(controller.page_nums(req, 100)).to cover(6, 7, 8, 9, 10)
        end
      end

      context "with page=10" do
        let(:uri) { '/admin/bimac-honda-la?page=10' }
        it "covers 6-10" do
          expect(controller.page_nums(req, 100)).to cover(6, 7, 8, 9, 10)
        end
      end

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

  # NOTE: These aren't specs so much as alerts that this changed (if it does)
  describe "::SPREAD" do

    it "exists" do
      expect(Lynr::Controller::Paginated::SPREAD).to be
    end

    it "is 10" do
      expect(Lynr::Controller::Paginated::SPREAD).to eq(2)
    end

  end

end
