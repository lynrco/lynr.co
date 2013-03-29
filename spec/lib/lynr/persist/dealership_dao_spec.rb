require 'rspec/autorun'
require 'yaml'
require './lib/lynr/persist/dealership_dao'

require './lib/lynr/model/address'
require './lib/lynr/model/identity'
require './lib/lynr/model/image'

describe Lynr::Persist::DealershipDao do

  let(:address) {
    Lynr::Model::Address.new(
      line_one="Addr L1", line_two="Addr L2", city="New York", state="NY", zip="10002"
    )
  }
  let(:identity) { Lynr::Model::Identity.new('bryan@lynr.co', 'this is a fake password') }
  let(:image) { Lynr::Model::Image.new("300", "150", "//lynr.co/assets/image.gif") }
  let(:dao) { Lynr::Persist::DealershipDao.new }

  describe "#get result" do

    let(:record) {
      {
        name: 'CarMax San Diego',
        phone: '+1 123-123-1234',
        image: image.view,
        address: address.view,
        identity: identity.view
      }
    }

    before(:each) do
      Lynr::Persist::MongoDao.any_instance.stub(:read) do |id|
        record[:_id] = id
        record
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

  end

  describe "#save result" do

    let(:dealer_data) {
      {
        name: 'CarMax San Diego',
        phone: '+1 123-123-1234',
        image: image,
        address: address,
        identity: identity
      }
    }

    before(:each) do
      Lynr::Persist::MongoDao.any_instance.stub(:save) do |record, id|
        result = record.dup
        result[:_id] = id
        result
      end
    end

    it "is a Dealership instance" do
      dealer = Lynr::Model::Dealership.new(dealer_data)
      expect(dao.save(dealer)).to be_an_instance_of(Lynr::Model::Dealership)
    end

    it "has the same data" do
      saved = dao.save(Lynr::Model::Dealership.new(dealer_data))
      expect(saved.name).to eq(dealer_data[:name])
      expect(saved.phone).to eq(dealer_data[:phone])
      expect(saved.address).to eq(address)
      expect(saved.image).to eq(image)
      expect(saved.identity.auth?('bryan@lynr.co', 'this is a fake password')).to be_true
    end

  end

end
