require 'rspec/autorun'
require './spec/spec_helper'

require 'yaml'
require './lib/lynr/config'

describe Lynr::Config do

  before(:each) do
    root = RSpec.configuration.root
    whereami = RSpec.configuration.whereami
    @config = YAML.load_file("#{root}/config/database.#{whereami}.yaml")
  end

  let(:config_type) { 'database' }
  let(:config_env) { 'spec' }
  let(:config) { Lynr::Config.new('database', 'spec') }

  describe "#initialize" do

    it "sets up environment" do
      c = Lynr::Config.new(config_type, config_env)
      expect(c.environment).to eq(config_env)
    end

    it "sets up type" do
      c = Lynr::Config.new(config_type, config_env)
      expect(c.type).to eq(config_type)
    end

    it "can be set up with defaults" do
      c = Lynr::Config.new(config_type, config_env, { 'default_value' => 'this is my default value' })
      expect(@config['default_value']).to be_nil
      expect(c['default_value']).to eq('this is my default value')
    end

    it "merges hashes one level deep with defaults" do
      c = Lynr::Config.new(config_type, config_env, { 'mongo' => { 'collection' => 'hi' } })
      expect(@config['mongo']['collection']).to be_nil
      expect(c['mongo']['collection']).to eq('hi')
    end

    it "contains values if given `nil` for defaults" do
      c = Lynr::Config.new(config_type, config_env, nil)
      expect(@config['int_val']).to eq(c['int_val'])
    end

  end

  context "without defaults" do

    describe ".[]" do

      it "reads an int value from YAML data and returns it" do
        expect(config['int_val']).to eq(1234)
      end

      it "reads an boolean value from YAML data and returns it" do
        expect(config['bool_val']).to equal(true)
      end

      it "reads an string value from YAML data and returns it" do
        expect(config['string_val']).to eq('hithere')
      end

      it "reads an env value from YAML data and parses it" do
        expect(config['env_val']).to eq(ENV['whereami'])
      end

      it "creates a new Config instead of a Hash" do
        expect(config['mongo']).to be_instance_of(Lynr::Config)
        expect(config['mongo']).to_not be_instance_of(Hash)
      end

      it "reads a value when key is symbol or string" do
        expect(config[:int_val]).to eq(1234)
      end

    end

  end

  context "with defaults" do

    let(:defaults) {
      { 'int_val' => 63, 'mongo' => { 'host' => '127.0.0.3' } }
    }
    let(:config) { Lynr::Config.new('database', 'spec', defaults) }

    describe ".[]" do

      it "reads an int value from YAML data and returns it" do
        expect(config['int_val']).to eq(63)
      end

      it "reads an boolean value from YAML data and returns it" do
        expect(config['bool_val']).to equal(true)
      end

      it "reads an string value from YAML data and returns it" do
        expect(config['string_val']).to eq('hithere')
      end

      it "reads an env value from YAML data and parses it" do
        expect(config['env_val']).to eq(ENV['whereami'])
      end

      it "creates a new Config instead of a Hash" do
        expect(config['mongo']).to be_instance_of(Lynr::Config)
        expect(config['mongo']).to_not be_instance_of(Hash)
      end

      it "reads provides the nested host value passed into config" do
        expect(config['mongo']['host']).to eq('127.0.0.3')
      end

      it "reads a value when key is symbol or string" do
        expect(config[:int_val]).to eq(1234)
      end

    end

  end

end
