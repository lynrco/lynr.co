require './lib/lynr/events'
require './lib/lynr/events/handler/logger'

describe Lynr::Events::Consumer do

  subject(:consumer) { Lynr::Events::Consumer.new }
  let(:handler) { Lynr::Events::Handler::Logger.new }

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

  describe '#handlers_for' do
    before(:each) do
      consumer.add('*', handler)
      consumer.add('dealership', handler)
      consumer.add('dealership.created', handler)
      consumer.add('dealership.created.demo', handler)
    end
    context 'with empty type' do
      it { expect(consumer.handlers_for({}).length).to eq(1) }
    end
    context 'with dealership.created type' do
      let(:evt) { { type: 'dealership.created' } }
      it { expect(consumer.handlers_for(evt).length).to eq(3) }
    end
    context 'with dealership.created.demo type' do
      let(:evt) { { type: 'dealership.created.demo' } }
      it { expect(consumer.handlers_for(evt).length).to eq(4) }
    end
  end

end
