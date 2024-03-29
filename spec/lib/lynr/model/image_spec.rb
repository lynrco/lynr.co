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
      expect(image.width).to eq(300)
      expect(image.width).to be_a(Numeric)
    end

    it "converts height to integer" do
      expect(image.height).to eq(150)
      expect(image.height).to be_a(Numeric)
    end

    it "converts strings to integers" do
      expect(image).to eq(@image)
    end

    it "creates a blank image with no args" do
      image = Lynr::Model::Image.new
      expect(image.url).to eq("/img/blank.gif")
      expect(image.width).to eq(0)
      expect(image.height).to eq(0)
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

  describe ".inflatable?" do

    it "is inflatable if it has the keys width, height, url" do
      image_props = { 'width' => "300", 'height' => "150", 'url' => @url }
      expect(Lynr::Model::Image.inflatable?(image_props)).to be_true
    end

    it "is not inflatable if it is missing width" do
      image_props = { 'height' => "150", 'url' => @url }
      expect(Lynr::Model::Image.inflatable?(image_props)).to be_false
    end

    it "is not inflatable if it is missing height" do
      image_props = { 'width' => "300", 'url' => @url }
      expect(Lynr::Model::Image.inflatable?(image_props)).to be_false
    end

    it "is not inflatable if it is missing url" do
      image_props = { 'width' => "300", 'height' => "150" }
      expect(Lynr::Model::Image.inflatable?(image_props)).to be_false
    end

  end

end
