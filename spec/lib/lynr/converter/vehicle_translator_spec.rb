require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/converter/vehicle_translator'

describe Lynr::Converter::VehicleTranslator do

  let(:translator) { Lynr::Converter::VehicleTranslator.new }

  describe "#condition" do

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

end
