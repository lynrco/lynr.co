require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/address'
require './lib/lynr/model/dealership'
require './lib/lynr/model/identity'
require './lib/lynr/model/sized_image'

describe Lynr::Model::Dealership do

  let(:address) { "122 Forsyth St\nApt 4D" }
  let(:identity) { Lynr::Model::Identity.new('bryan@lynr.co', 'this is a fake password') }
  let(:img) { Lynr::Model::Image.new("300", "150", "//lynr.co/assets/image.gif") }
  let(:image) { Lynr::Model::SizedImage.new({ 'original' => img }) }

  describe "#==" do

    let(:dealer) { Lynr::Model::Dealership.new({ 'name' => 'Fun Times', 'address' => address }) }

    it "is true if properties are the same" do
      d = Lynr::Model::Dealership.new({ 'name' => 'Fun Times', 'address' => address })
      expect(d).to eq(dealer)
    end

    it "is false if properties are not the same" do
      d = Lynr::Model::Dealership.new({ 'name' => 'Fun Times2', 'address' => address })
      expect(d).to_not eq(dealer)
    end

    it "is false if complex properties are not the same" do
      d1 = dealer.set({ 'image' => image })
      d2 = dealer.set({ 'image' => Lynr::Model::Image.new("301", "150", "//lynr.co/assets/image.gif") })
      expect(d2).to_not eq(d1)
      expect(d1).to_not eq(d2)
    end

    it "is true if complex properties are the same" do
      d1 = dealer.set({ 'image' => Lynr::Model::Image.new("301", "150", "//lynr.co/assets/image.gif") })
      d2 = dealer.set({ 'image' => Lynr::Model::Image.new("301", "150", "//lynr.co/assets/image.gif") })
      expect(d2).to eq(d1)
      expect(d1).to eq(d2)
    end

    it "is false if types are different" do
      image = Lynr::Model::Image.new("301", "150", "//lynr.co/assets/image.gif")
      expect(dealer).to_not eq(image)
    end

    it "is false if types are different but values are the same" do
      expect(dealer).to_not eq(dealer.view)
    end

  end

  describe "#set" do

    let(:dealer) {
      Lynr::Model::Dealership.new({
        'name' => 'CarMax San Diego',
        'phone' => '+1 123-123-1234',
        'address' => address,
        'image' => image,
        'identity' => identity
      })
    }

    it "returns a new Dealership instance" do
      expect(dealer.set({})).to_not equal(dealer)
    end

    it "returns an equivalent instance if no fields are passed" do
      expect(dealer.set({})).to eq(dealer)
    end

    it "updates a simple field if passed" do
      expect(dealer.set({ 'name' => 'CarMax' }).name).to eq('CarMax')
    end

    it "updates a complex field if passed" do
      dummy_image = Lynr::Model::Image.new("300", "150", "//lynr.co/assets/dummy.gif")
      dummy_dealer = dealer.set({ 'image' => dummy_image })
      expect(dummy_dealer.image).to eq(dummy_image)
      expect(dummy_dealer.image).to_not eq(image)
    end
    
  end

  describe ".inflate" do

    let(:record) {
      {
        'name' => 'CarMax San Diego',
        'phone' => '+1 123-123-1234',
        'address' => address,
        'image' => image.view,
        'identity' => identity.view
      }
    }
    let(:dealer) { Lynr::Model::Dealership.inflate(record) }

    context ".address" do

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
        expect(dealer.image).to be_an_instance_of(Lynr::Model::SizedImage)
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
