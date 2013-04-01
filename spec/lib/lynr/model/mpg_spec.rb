require 'rspec/autorun'
require './spec/spec_helpers'

require './lib/lynr/model/mpg'

describe Lynr::Model::Mpg do

  let(:mpg_props) { { 'city' => 28.8, 'highway' => 33.2 } }
  let(:mpg) { Lynr::Model::Mpg.new(mpg_props) }

  describe ".inflate" do

    it "creates an equivalent object from a Hash" do
      expect(Lynr::Model::Mpg.inflate({ 'city' => 28.8, 'highway' => 33.2 })).to eq(mpg)
    end

  end

end
