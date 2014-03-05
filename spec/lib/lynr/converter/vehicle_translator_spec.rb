require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/converter/vehicle_translator'

describe Lynr::Converter::VehicleTranslator do

  class Translator
    include Lynr::Converter::VehicleTranslator
  end

  let(:translator) { Lynr::Converter::VehicleTranslator }

  shared_examples "VehicleTranslator.condition" do

    translations = {
      "4" => "Excellent Condition",
      "3" => "Good Condition",
      "2" => "Fair Condition",
      "1" => "Poor Condition",
      "0" => "Condition",
    }

    translations.each do |code, name|

      it "gets '#{name}' for '#{code}'" do
        expect(translator.condition(code)).to eq(name)
      end

    end

  end

  describe ".condition" do
    it_behaves_like "VehicleTranslator.condition" do
      let(:translator) { subject }
    end
  end

  describe "#condition" do
    it_behaves_like "VehicleTranslator.condition" do
      let(:translator) { Translator.new }
    end
  end

end
