require './lib/lynr/events'

describe Lynr::Events::Consumer do

  subject(:consumer) { Lynr::Events::Consumer.new }

  describe '#types_for' do
    context 'with empty type' do
      it { expect(consumer.types_for({})).to eq(Set.new(['*'])) }
    end
    context 'with dealership.created type' do
      let(:evt) { { type: 'dealership.created' } }
      let(:types) { Set.new(['*', 'dealership', 'dealership.created']) }
      it { expect(consumer.types_for(evt)).to eq(types) }
    end
    context 'with dealership.created.demo type' do
      let(:evt) { { type: 'dealership.created.demo' } }
      let(:types) {
        Set.new(['*', 'dealership', 'dealership.created', 'dealership.created.demo'])
      }
      it { expect(consumer.types_for(evt)).to eq(types) }
    end
  end

end
