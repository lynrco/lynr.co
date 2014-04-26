require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/persist/dealership_dao'

require './lib/lynr/model/address'
require './lib/lynr/model/identity'
require './lib/lynr/model/slug'
require './lib/lynr/model/sized_image'

describe Lynr::Persist::DealershipDao do

  let(:ebay_account) {
    Lynr::Model::EbayAccount.new(
      'expires' => Time.parse('2015-07-02T23:36:35.000Z'),
      'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
      'token'   => 'YourAuthToken',
    )
  }
  let(:accounts) { Lynr::Model::Accounts.new([ ebay_account ]) }
  let(:address) { Lynr::Model::Address.new('line_one' => "122 Forsyth St\nApt 4D") }
  let(:identity) { Lynr::Model::Identity.new('bryan@lynr.co', 'this is a fake password') }
  let(:img) { Lynr::Model::Image.new("300", "150", "//lynr.co/assets/image.gif") }
  let(:image) { Lynr::Model::SizedImage.new({ 'original' => img }) }
  let(:dao) { Lynr::Persist::DealershipDao.new }
  let(:dealer_data) {
    {
      'name' => 'CarMax San Diego',
      'phone' => '+1 123-123-1234',
      'accounts' => accounts,
      'address' => address,
      'image' => image,
      'identity' => identity
    }
  }


  describe "#get result" do

    let(:record) {
      {
        'name' => 'CarMax San Diego',
        'phone' => '+1 123-123-1234',
        'accounts' => accounts.view,
        'address' => address.view,
        'image' => image.view,
        'identity' => identity.view
      }
    }

    before(:each) do
      Lynr::Persist::MongoDao.any_instance.stub(:read) do |id|
        if id.nil?
          nil
        else
          record['_id'] = id
          record
        end
      end
    end

    it "a Dealership instance" do
      dealer = dao.get("678928376")
      expect(dealer).to be_an_instance_of(Lynr::Model::Dealership)
    end

    it "a dealer with given id" do
      dealer = dao.get("678928376")
      expect(dealer.id).to eq("678928376")
    end

    it "returns nil when given nil" do
      expect(dao.get(nil)).to be_nil
    end

  end

  describe "#save result" do

    before(:each) do
      Lynr::Persist::MongoDao.any_instance.stub(:save) do |record, id|
        result = record.dup
        result['_id'] = id
        result
      end
    end

    it "is a Dealership instance" do
      dealer = Lynr::Model::Dealership.new(dealer_data)
      expect(dao.save(dealer)).to be_an_instance_of(Lynr::Model::Dealership)
    end

    it "has the same data" do
      saved = dao.save(Lynr::Model::Dealership.new(dealer_data))
      expect(saved.name).to eq(dealer_data['name'])
      expect(saved.phone).to eq(dealer_data['phone'])
      expect(saved.address).to eq(address)
      expect(saved.image).to eq(image)
      expect(saved.identity.auth?('bryan@lynr.co', 'this is a fake password')).to be_true
    end

  end

  context "with active connection", :if => (MongoHelpers.connected?) do

    let(:customer_id) { "cus_1bFL8vciXXchnm" }
    let(:dealer) { Lynr::Model::Dealership.new(dealer_data) }
    let(:dealership) {
      Lynr::Model::Dealership.new({ 'identity' => identity, 'customer_id' => customer_id })
    }
    let(:saved) { dao.save(dealership) }
    let(:slug) { Lynr::Model::Slug.new(dealer_data['name'], nil) }

    describe "#account_exists?" do

      it "returns false if email isn't taken" do
        expect(dao.account_exists?(identity.email)).to be_false
      end

      it "returns true if email is taken" do
        dao.save(dealership)
        expect(dao.account_exists?(identity.email)).to be_true
      end

    end

    describe "#save" do

      it "is a Dealership instance" do
        expect(dao.save(dealer)).to be_an_instance_of(Lynr::Model::Dealership)
      end

      it "has an id" do
        expect(dao.save(dealer).id).to be
      end

      it "keeps its id on updates" do
        saved = dao.save(dealer)
        id = saved.id
        expect(dao.save(saved).id).to eq(id)
      end

      context "customer_id not unique" do

        let(:dealership) {
          Lynr::Model::Dealership.new(dealer_data.merge({ 'customer_id' => customer_id}))
        }
        let(:to_save) {
          dealership.set({
            'customer_id' => customer_id,
            'identity' => Lynr::Model::Identity.new('bryan+t@lynr.co', identity.password)
          })
        }

        before(:each) do
          dao.save(dealership)
        end

        it "raises DataError" do
          expect { dao.save(to_save) }.to raise_error(Lynr::DataError)
        end

        it "raises error with field == customer_id" do
          expect { dao.save(to_save) }.to raise_error { |err|
            expect(err.field).to eq('customer_id')
          }
        end

        it "raises error with value == cus_1bFL8vciXXchnm" do
          expect { dao.save(to_save) }.to raise_error { |err|
            expect(err.value).to eq('cus_1bFL8vciXXchnm')
          }
        end

      end

    end

    describe "#get" do

      it "resolves DBRef to Dealership" do
        ref = BSON::DBRef.new('dealers', saved.id)
        expect(dao.get(ref)).to eq(saved)
      end

      it "is nil if DBRef is for different collection" do
        ref = BSON::DBRef.new('vehicles', saved.id)
        expect(dao.get(ref)).to be_nil
      end

      it "resolves String to ObjectId" do
        expect(dao.get(saved.id.to_s)).to eq(saved)
      end

    end

    describe "#get_by_email" do

      it "returns nil if dealership with email doesn't exist" do
        expect(dao.get_by_email(identity.email)).to be_nil
      end

      it "returns dealership if dealership with email exists" do
        saved = dao.save(dealership)
        expect(dao.get_by_email(identity.email).id).to eq(saved.id)
      end

    end

    describe "#get_by_customer_id" do

      it "returns nil if customer_id doesn't exist" do
        expect(dao.get_by_customer_id(customer_id)).to be_nil
      end

      it "returns dealership if customer_id exists" do
        saved = dao.save(dealership)
        expect(dao.get_by_customer_id(customer_id).id).to eq(saved.id)
      end

    end

    describe "#get_by_slug" do

      it "returns nil if slug doesn't exist" do
        expect(dao.get_by_slug(slug)).to be_nil
      end

      it "returns dealership if slug exists" do
        saved = dao.save(dealership.set(dealer_data))
        expect(dao.get_by_slug(slug)).to be_an_instance_of(Lynr::Model::Dealership)
      end

      it "returns saved dealership if slug exists" do
        saved = dao.save(dealership.set(dealer_data))
        expect(dao.get_by_slug(slug)).to eq(saved)
      end

    end

    describe "slug_exists?" do

      it "returns false if slug doesn't exist" do
        expect(dao.slug_exists?(slug)).to be_false
      end

      it "returns true if slug exists" do
        saved = dao.save(dealer)
        expect(dao.slug_exists?(slug)).to be_true
      end

    end

  end

end
