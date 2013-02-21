require 'rspec/autorun'
require 'yaml'
require './lib/quicklist/persist/dealership_dao'

require './lib/quicklist/model/address'
require './lib/quicklist/model/identity'
require './lib/quicklist/model/image'

describe Quicklist::Persist::DealershipDao do

  let(:address) {
    Quicklist::Model::Address.new(
      line_one="Addr L1", line_two="Addr L2", city="New York", state="NY", zip="10002"
    )
  }
  let(:identity) { Quicklist::Model::Identity.new('bryan@quicklist.it', 'this is a fake password') }
  let(:image) { Quicklist::Model::Image.new("300", "150", "//quicklist.it/assets/image.gif") }
  let(:dao) { Quicklist::Persist::DealershipDao.new }

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
      Quicklist::Persist::MongoDao.any_instance.stub(:get) do |id|
        record[:_id] = id
        record
      end
    end

    it "a Dealership instance" do
      dealer = dao.get("678928376")
      expect(dealer).to be_an_instance_of(Quicklist::Model::Dealership)
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
      Quicklist::Persist::MongoDao.any_instance.stub(:save) do |record, id|
        result = record.dup
        result[:_id] = id
        result
      end
    end

    it "is a Dealership instance" do
      dealer = Quicklist::Model::Dealership.new(dealer_data)
      expect(dao.save(dealer)).to be_an_instance_of(Quicklist::Model::Dealership)
    end

    it "has the same data" do
      saved = dao.save(Quicklist::Model::Dealership.new(dealer_data))
      expect(saved.name).to eq(dealer_data[:name])
      expect(saved.phone).to eq(dealer_data[:phone])
      expect(saved.address).to eq(address)
      expect(saved.image).to eq(image)
      expect(saved.identity.auth?('bryan@quicklist.it', 'this is a fake password')).to be_true
    end

  end

end
