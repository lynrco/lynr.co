require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/mpg'

describe Lynr::Model::Mpg do

  let(:mpg_props) { { 'city' => 28.8, 'highway' => 33.2 } }
  let(:mpg) { Lynr::Model::Mpg.new(mpg_props) }
  let(:empty_mpg) { Lynr::Model::Mpg.new }

  describe "#initialize" do

    it "provides an empty Mpg instance for no args" do
      expect(empty_mpg.city).to eq(0.0)
      expect(empty_mpg.highway).to eq(0.0)
    end

  end

  describe ".inflate" do

    it "provides an empty Mpg instance for nil" do
      expect(Lynr::Model::Mpg.inflate(nil)).to eq(empty_mpg)
    end

    it "creates an equivalent object from a Hash" do
      expect(Lynr::Model::Mpg.inflate({ 'city' => 28.8, 'highway' => 33.2 })).to eq(mpg)
    end

  end

end
