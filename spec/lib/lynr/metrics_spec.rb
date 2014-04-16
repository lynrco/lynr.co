require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/config'
require './lib/lynr/metrics'

describe Lynr::Metrics do

  include_context "spec/support/ConfigHelper"

  let(:librato_config) {
    {
      'user'   => 'bryan@lynr.co',
      'token'  => "I'm not real",
      'source' => 'lynr.specs',
    }
  }

  describe "#add" do

    before(:each) do
      Librato::Metrics::Queue.any_instance.stub(:add) do |metrics|
        self
      end
    end

  end

  describe "#configured?" do

    it "is true when given config with user, token and source" do
      config = Lynr::Config.new(nil, 'neverland', librato_config)
      expect(subject.configured?(config)).to be_true
    end

    ['user', 'token', 'source'].each do |key|

      let(:config) { Lynr::Config.new(nil, 'neverland', librato) }

      it "is false when given config without #{key}" do
        librato = librato_config.delete_if { |k,v| k == key }
        config = Lynr::Config.new(nil, 'neverland', librato)
        expect(subject.configured?(config)).to be_false
      end

      it "is false when given config with only #{key}" do
        librato = librato_config.delete_if { |k,v| k != key }
        config = Lynr::Config.new(nil, 'neverland', librato)
        expect(subject.configured?(config)).to be_false
      end

    end

  end

  describe "#queue" do

    let(:queue) { subject.queue(librato_config) }
    let(:client) { queue.client }

    it "returns an instance of Librato::Metrics::Queue" do
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

    it "has a client" do
      expect(queue.client).to be
    end

    it "has an instance of Librato::Metrics::Client" do
      expect(queue.client).to be_instance_of(Librato::Metrics::Client)
    end

    it "has a client with email" do
      expect(client.email).to eq(librato_config['user'])
    end

    it "has a client with an api_key" do
      expect(client.api_key).to eq(librato_config['token'])
    end

    context "when #configured? is false" do

      let(:librato_config) {
        {
          'user'   => 'bryan@lynr.co',
          'token'  => "I'm not real",
        }
      }

      it "has a client without email" do
        expect(client.email).to be_nil
      end

      it "has a client without api_key" do
        expect(client.api_key).to be_nil
      end

    end

    context "with no explicit config" do

      before(:each) do
        stub_config('app', {
          'librato' => {
            'user' => 'foo@bar.com',
            'token' => 'madeup',
            'source' => 'lynr-co-spec',
          }
        })
      end

      let(:queue) { subject.queue }
      let(:config) { Lynr.config('app') }

      it "has a client with email from Lynr.config" do
        expect(client.email).to eq(config.librato.user)
      end

      it "has a client with api_key from Lynr.config" do
        expect(client.api_key).to eq(config.librato.token)
      end

    end

  end

end
