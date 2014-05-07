require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/config'
require './lib/lynr/metrics'

describe Lynr::Metrics do

  include_context "spec/support/ConfigHelper"

  subject(:metrics) { Lynr::Metrics.new }
  subject(:aggregator) { metrics.aggregator }
  subject(:queue) { metrics.queue }

  def librato_config
    {
      'enabled' => true,
      'user'    => 'bryan@lynr.co',
      'token'   => "I'm not real",
      'source'  => 'lynr.specs',
    }
  end

  describe "EMPTY_PROCESSOR" do
    subject(:queue) { Lynr::Metrics::EMPTY_PROCESSOR }
    it "should have nil client" do expect(queue.client).to be_nil end
    it "should be empty" do expect(queue.empty?).to be_true end
  end

  context "with full librato config" do

    before(:all) do
      stub_config('app', 'librato' => {
        'enabled' => true,
        'user'    => 'bryan@lynr.co',
        'token'   => "I'm not real",
        'source'  => 'lynr.specs',
      })
    end

    describe "#aggregator" do
      it { expect(aggregator).to be_instance_of(Librato::Metrics::Aggregator) }
      # NOTE: Dangerous spec, testing implementation details of a dependency,
      # because this value isn't exposed
      it "has an autosubmit_interval set" do
        expect(aggregator.instance_variable_get(:@autosubmit_interval)).to eq(90)
      end
      it { expect(aggregator.client).to be_instance_of(Librato::Metrics::Client) }
    end

    describe "#configured?" do

      it "is true when given config with user, token and source" do
        expect(metrics.configured?).to be_true
      end

    end

    describe "#queue" do

      it "is an instance of Librato::Metrics::Queue" do
        expect(queue).to be_instance_of(Librato::Metrics::Queue)
      end

      # NOTE: Dangerous spec, testing implementation details of a dependency,
      # because this value isn't exposed
      it "has an autosubmit_count set" do
        expect(queue.instance_variable_get(:@autosubmit_count)).to eq(15)
      end

      # NOTE: Dangerous spec, testing implementation details of a dependency,
      # because this value isn't exposed
      it "has an autosubmit_interval set" do
        expect(queue.instance_variable_get(:@autosubmit_interval)).to eq(90)
      end

      it "has an instance of Librato::Metrics::Client" do
        expect(queue.client).to be_instance_of(Librato::Metrics::Client)
      end

      it "has a client with email" do
        expect(queue.client.email).to eq(librato_config['user'])
      end

      it "has a client with an api_key" do
        expect(queue.client.api_key).to eq(librato_config['token'])
      end

    end

    describe "#timeshift" do
      before(:each) do
        metrics.client.persistence = :test
      end
      it "should be true if there are no metrics" do
        expect(metrics.timeshift(queue)).to be_true
      end
      it "should be true if there are metrics" do
        queue.add({ load: 0.0 })
        expect(metrics.timeshift(queue)).to be_true
      end
    end

  end

  ['user', 'token', 'source'].each do |key|

    context "with partial config -- #{key} missing" do
      before(:all) do
        stub_config('app', 'librato' => librato_config.delete_if { |k,v| k == key })
      end
      describe "#configured?" do
        it { expect(metrics.configured?).to be_false }
      end
      describe "#enabled?" do
        it { expect(metrics.enabled?).to be_true }
      end
      describe "#queue" do
        it "should be EMPTY_PROCESSOR" do expect(queue).to eq(Lynr::Metrics::EMPTY_PROCESSOR) end
      end
    end

  end

  context "with no librato config" do
    before(:all) do
      stub_config('app', 'librato' => nil)
    end
    describe "#configured?" do
      it { expect(metrics.configured?).to be_false }
    end
    describe "#enabled?" do
      it { expect(metrics.enabled?).to be_false }
    end
    describe "#queue" do
      it "should be EMPTY_PROCESSOR" do expect(queue).to eq(Lynr::Metrics::EMPTY_PROCESSOR) end
    end
  end

end
