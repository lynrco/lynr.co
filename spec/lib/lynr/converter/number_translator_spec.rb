require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/converter/number_translator'

describe Lynr::Converter::NumberTranslator do

  shared_examples "NumberTranslator.delimit" do

    translations = {
      "100" => "100",
      "1000" => "1,000",
      "10000" => "10,000",
      "10,000" => "10,000",
      "bud4ee" => "4",
      "500000" => "500,000",
      "hi there" => "0",
      "$12,995" => "12,995",
    }

    translations.each do |raw, formatted|

      it "gets '#{formatted}' for '#{raw}'" do
        expect(translator.delimit(raw)).to eq(formatted)
      end

    end

  end

  describe ".delimit" do
    it_behaves_like "NumberTranslator.delimit" do
      let(:translator) { Lynr::Converter::NumberTranslator }
    end
  end

  describe "#delimit" do
    it_behaves_like "NumberTranslator.delimit" do
      class Translator
        include Lynr::Converter::NumberTranslator
      end
      let(:translator) { Translator.new }
    end
  end

end
