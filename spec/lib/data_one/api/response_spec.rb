require 'rspec/autorun'
require './spec/spec_helper'

require './lib/data_one'
require './lib/data_one/api'
require './lib/data_one/api/response'

describe DataOne::Api::Response do

  subject(:response) { DataOne::Api::Response.new(xml) }
  let(:xml) { File.read('./spec/data/1HGEJ6229XL063838.xml') }

  context 'with no decoder_errors/error' do
    describe '#errors' do
      it { expect(response.errors).to be_empty }
    end
    describe '#success?' do
      it { expect(response.success?).to be_true }
    end
  end

  context 'with decoder_errors/error' do
    let(:xml) { File.read('./spec/data/1HGEJ6229XL063838-error.xml') }
    describe '#errors' do
      it { expect(response.errors).to_not be_empty }
      it { expect(response.errors.length).to eq(1) }
    end
    describe '#success?' do
      it { expect(response.success?).to be_false }
    end
  end

end
