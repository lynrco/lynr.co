require 'rspec/autorun'
require './lib/quicklist/model/address'
require './lib/quicklist/model/dealership'
require './lib/quicklist/model/identity'
require './lib/quicklist/model/image'

describe Lynr::Model::Dealership do

  let(:address) {
    Lynr::Model::Address.new(
      line_one="Addr L1", line_two="Addr L2", city="New York", state="NY", zip="10002"
    )
  }
  let(:identity) { Lynr::Model::Identity.new('bryan@lynr.co', 'this is a fake password') }
  let(:image) { Lynr::Model::Image.new("300", "150", "//lynr.co/assets/image.gif") }

  describe ".inflate" do

    let(:record) {
      {
        name: 'CarMax San Diego',
        phone: '+1 123-123-1234',
        image: image.view,
        address: address.view,
        identity: identity.view
      }
    }
    let(:dealer) { Lynr::Model::Dealership.inflate(record) }

    context ".address" do

      it "is a Lynr::Model::Address" do
        expect(dealer.address).to be_an_instance_of(Lynr::Model::Address)
      end

      it "is the same as constructing address" do
        expect(dealer.address).to eq(address)
      end

    end

    context ".identity" do

      it "is a Lynr::Model::Identity" do
        expect(dealer.identity).to be_an_instance_of(Lynr::Model::Identity)
      end

      it "auths the same as the constructing identity" do
        expect(dealer.identity.auth?('bryan@lynr.co', 'this is a fake password')).to be_true
        expect(dealer.identity.auth?('bryan@lynr.co', 'this is not a fake password')).to be_false
      end

    end

    context ".image" do

      it "is a Lynr::Model::Image" do
        expect(dealer.image).to be_an_instance_of(Lynr::Model::Image)
      end

      it "is the same as the constructing image" do
        expect(dealer.image).to eq(image)
      end

    end

    it "returns nil when given nil" do
      expect(Lynr::Model::Dealership.inflate(nil)).to be_nil
    end

  end

end
