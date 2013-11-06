require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/sized_image'

describe Lynr::Model::SizedImage do

  let(:original) { Lynr::Model::Image.new("300", "150", "/img/original.png") }
  let(:full) { Lynr::Model::Image.new("300", "150", "/img/full.png") }
  let(:thumb) { Lynr::Model::Image.new("300", "150", "/img/thumb.png") }
  let(:empty) { Lynr::Model::SizedImage.new() }

  describe "#url" do

    it "is blank.gif if original, full and thumb are empty" do
      expect(empty.url).to eq('/img/blank.gif')
    end

    it "is original.url if original is not empty" do
      image = Lynr::Model::SizedImage.new({ 'original' => original, 'full' => full, 'thumb' => thumb })
      expect(image.url).to eq(original.url)
    end

    it "is full.url if original is empty and full is not empty" do
      image = Lynr::Model::SizedImage.new({ 'full' => full })
      expect(image.url).to eq(full.url)
      image = Lynr::Model::SizedImage.new({ 'full' => full, 'thumb' => thumb })
      expect(image.url).to eq(full.url)
    end

    it "is thumb.url if original and full are empty and thumb is not" do
      image = Lynr::Model::SizedImage.new({ 'thumb' => thumb })
      expect(image.url).to eq(thumb.url)
    end

  end

  describe "#width" do

    it "is 0 if original, full and thumb are empty" do
      expect(empty.width).to eq(0)
    end

    it "is original.width if original is not empty" do
      image = Lynr::Model::SizedImage.new({ 'original' => original, 'full' => full, 'thumb' => thumb })
      expect(image.width).to eq(original.width)
    end

    it "is full.width if original is empty and full is not empty" do
      image = Lynr::Model::SizedImage.new({ 'full' => full })
      expect(image.width).to eq(full.width)
      image = Lynr::Model::SizedImage.new({ 'full' => full, 'thumb' => thumb })
      expect(image.width).to eq(full.width)
    end

    it "is thumb.width if original and full are empty and thumb is not" do
      image = Lynr::Model::SizedImage.new({ 'thumb' => thumb })
      expect(image.width).to eq(thumb.width)
    end

  end

  describe "#height" do

    it "is 0 if original, full and thumb are empty" do
      expect(empty.height).to eq(0)
    end

    it "is original.height if original is not empty" do
      image = Lynr::Model::SizedImage.new({ 'original' => original, 'full' => full, 'thumb' => thumb })
      expect(image.height).to eq(original.height)
    end

    it "is full.height if original is empty and full is not empty" do
      image = Lynr::Model::SizedImage.new({ 'full' => full })
      expect(image.height).to eq(full.height)
      image = Lynr::Model::SizedImage.new({ 'full' => full, 'thumb' => thumb })
      expect(image.height).to eq(full.height)
    end

    it "is thumb.height if original and full are empty and thumb is not" do
      image = Lynr::Model::SizedImage.new({ 'thumb' => thumb })
      expect(image.height).to eq(thumb.height)
    end

  end

  describe ".inflate" do

    it "gives an empty SizedImage by default" do
      image = Lynr::Model::SizedImage.inflate({})
      expect(image.empty?).to be_true
    end

    it "sets original if passed in record" do
      image = Lynr::Model::SizedImage.inflate({ 'original' => original })
      expect(image.original).to eq(original)
    end

    it "sets full if passed in record" do
      image = Lynr::Model::SizedImage.inflate({ 'full' => full })
      expect(image.full).to eq(full)
    end

    it "sets thumb if passed in record" do
      image = Lynr::Model::SizedImage.inflate({ 'thumb' => thumb })
      expect(image.thumb).to eq(thumb)
    end

    it "creates original Image if image view is passed" do
      image = Lynr::Model::SizedImage.inflate({ 'original' => original.view })
      expect(image.original).to eq(original)
    end

  end

end
