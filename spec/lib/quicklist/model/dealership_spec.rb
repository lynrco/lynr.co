require 'rspec/autorun'
require './lib/quicklist/model/address'
require './lib/quicklist/model/dealership'
require './lib/quicklist/model/identity'
require './lib/quicklist/model/image'

describe Quicklist::Model::Dealership do

  let(:address) {
    Quicklist::Model::Address.new(
      line_one="Addr L1", line_two="Addr L2", city="New York", state="NY", zip="10002"
    )
  }
  let(:identity) { Quicklist::Model::Identity.new('bryan@quicklist.it', 'this is a fake password') }
  let(:image) { Quicklist::Model::Image.new("300", "150", "//quicklist.it/assets/image.gif") }

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
    let(:dealer) { Quicklist::Model::Dealership.inflate(record) }

    context ".address" do

      it "is a Quicklist::Model::Address" do
        expect(dealer.address).to be_an_instance_of(Quicklist::Model::Address)
      end

      it "is the same as constructing address" do
        expect(dealer.address).to eq(address)
      end

    end

    context ".identity" do

      it "is a Quicklist::Model::Identity" do
        expect(dealer.identity).to be_an_instance_of(Quicklist::Model::Identity)
      end

      it "auths the same as the constructing identity" do
        expect(dealer.identity.auth?('bryan@quicklist.it', 'this is a fake password')).to be_true
        expect(dealer.identity.auth?('bryan@quicklist.it', 'this is not a fake password')).to be_false
      end

    end

    context ".image" do

      it "is a Quicklist::Model::Image" do
        expect(dealer.image).to be_an_instance_of(Quicklist::Model::Image)
      end

      it "is the same as the constructing image" do
        expect(dealer.image).to eq(image)
      end

    end

    it "returns nil when given nil" do
      expect(Quicklist::Model::Dealership.inflate(nil)).to be_nil
    end

  end

end
