require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/image'

describe Lynr::Model::Image do

  before(:all) do
    @url = "//lynr.co/assets/image.gif"
    @image = Lynr::Model::Image.new(300, 150, @url)
  end

  let(:image) { Lynr::Model::Image.new("300", "150", @url) }
  let(:empty_image) { Lynr::Model::Image.new(nil, nil, nil) }

  describe "#initialize" do

    it "converts width to integer" do
      image.width.should be(300)
      image.width.should_not be("300")
    end

    it "converts height to integer" do
      image.height.should be(150)
      image.height.should_not be("150")
    end

    it "converts strings to integers" do
      image.should == @image
    end

  end

  describe "#url" do

    it "is blank.gif if url IS empty" do
      expect(empty_image.url).to eq("/img/blank.gif")
    end

    it "is url if url IS NOT empty" do
      expect(image.url).to eq("//lynr.co/assets/image.gif")
    end

  end

  describe "#empty?" do

    it "is true when url IS NOT set" do
      expect(empty_image.empty?).to be_true
    end

    it "is false when url IS set" do
      expect(image.empty?).to be_false
    end

  end

  describe "#view" do

    let(:view) { @image.view }

    it "has the right keys" do
      view.keys.should include('width', 'height', 'url')
    end

    it "has the right values" do
      view.values.should include(300, 150, @url)
    end

    it "has keys matching values" do
      expect(view['width']).to eq(300)
      expect(view['height']).to eq(150)
      expect(view['url']).to eq(@url)
    end

  end

  describe "#==" do

    it "is true if properties are the same" do
      expect(image == @image).to be_true
      expect(image.equal?(@image)).to be_false
    end

    it "is true if compared to a Hash representing the view" do
      expect(image == image.view).to be_true
    end

  end

  describe ".inflate" do

    it "creates equivalent Image instances from properties" do
      image_props = { 'width' => "300", 'height' => "150", 'url' => @url }
      expect(Lynr::Model::Image.inflate(image_props)).to eq(image)
    end

    it "provides an empty image for nil" do
      expect(Lynr::Model::Image.inflate(nil)).to eq(empty_image)
    end

  end

end
