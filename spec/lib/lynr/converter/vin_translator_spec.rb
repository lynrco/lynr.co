require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/converter/vin_translator'

describe Lynr::Converter::VinTranslator do

  class Translator
    include Lynr::Converter::VinTranslator
  end

  shared_examples "VinTranslator.drivetrain" do

    translations = {
      "AWD" => "All Wheel Drive",
      "FWD" => "Front Wheel Drive",
      "RWD" => "Rear Wheel Drive",
      "4x4" => "4x4",
      "4x2" => "4x2",
    }

    translations.each do |code, name|

      it "gets '#{name}' for '#{code}'" do
        expect(translator.drivetrain(code)).to eq(name)
      end

    end

  end

  describe ".drivetrain" do
    it_behaves_like "VinTranslator.drivetrain" do
      let(:translator) { subject }
    end
  end

  describe "#drivetrain" do
    it_behaves_like "VinTranslator.drivetrain" do
      let(:translator) { Translator.new }
    end
  end

  shared_examples "VinTranslator.fuel" do

    translations = {
      "B" => "BioDiesel",
      "D" => "Diesel",
      "F" => "Flex Fuel",
      "G" => "Gasoline",
      "I" => "Plug-in Hybrid",
      "L" => "Electric",
      "N" => "Natural Gas",
      "P" => "Petroleum",
      "Y" => "Gas/Electric Hybrid",
    }

    translations.each do |code, name|

      it "gets '#{name}' for '#{code}'" do
        expect(translator.fuel(code)).to eq(name)
      end

    end

  end

  describe ".fuel" do
    it_behaves_like "VinTranslator.fuel" do
      let(:translator) { subject }
    end
  end

  describe "#fuel" do
    it_behaves_like "VinTranslator.fuel" do
      let(:translator) { Translator.new }
    end
  end

  shared_examples "VinTranslator.transmission_type" do

    translations = {
      "A"   => "Automatic",
      "CVT" => "Continuously Variable",
      "M"   => "Manual",
    }

    translations.each do |code, name|

      it "gets '#{name}' for '#{code}'" do
        expect(translator.transmission_type(code)).to eq(name)
      end

    end

  end

  describe ".transmission_type" do
    it_behaves_like "VinTranslator.transmission_type" do
      let(:translator) { subject }
    end
  end

  describe "#transmission_type" do
    it_behaves_like "VinTranslator.transmission_type" do
      let(:translator) { Translator.new }
    end
  end

  shared_examples "VinTranslator.doors" do

    translations = {
      "2"   => "2 Doors",
      "3"   => "3 Doors",
      "4"   => "4 Doors",
      "5"   => "5 Doors",
      "two" => "N/A",
    }

    translations.each do |code, name|

      it "gets '#{name}' for '#{code}'" do
        expect(translator.doors(code)).to eq(name)
      end

    end

  end

  describe ".doors" do
    it_behaves_like "VinTranslator.doors" do
      let(:translator) { subject }
    end
  end

  describe "#doors" do
    it_behaves_like "VinTranslator.doors" do
      let(:translator) { Translator.new }
    end
  end

end
