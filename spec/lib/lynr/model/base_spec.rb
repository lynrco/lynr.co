require 'rspec/autorun'

require './lib/lynr/model/base'

describe Lynr::Model::Base do

  class Dummy
    include Lynr::Model::Base
  end

  let(:base) { Dummy.new }

  describe "#view" do

    it "returns an empty Hash" do
      expect(base.view).to eq({})
    end

  end

  describe "#to_json" do

    it "returns the JSON equivalent of an empty Hash" do
      expect(base.to_json).to eq({}.to_json)
    end

  end

end
