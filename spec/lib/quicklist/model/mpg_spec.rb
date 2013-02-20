require 'rspec/autorun'
require './lib/quicklist/model/mpg'

describe Quicklist::Model::Mpg do

  let(:mpg_props) { { city: 28.8, highway: 33.2 } }
  let(:mpg) { Quicklist::Model::Mpg.new(mpg_props) }

  describe ".inflate" do

    it "creates an equivalent object from a Hash" do
      expect(Quicklist::Model::Mpg.inflate(mpg_props)).to eq(mpg)
    end

  end

end
