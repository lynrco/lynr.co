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

      it "reads a false value from YAML data and returns it" do
        expect(config['false_val']).to equal(false)
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

    describe "#fetch" do

      it "reads 'false' as `false` when default is bool" do
        expect(config.fetch('str_bool_false', true)).to eq(false)
      end

      it "reads 'true' as `true` when default is bool" do
        expect(config.fetch('str_bool_true', false)).to eq(true)
      end

      it "reads 0 as 'false' when default is bool" do
        expect(config.fetch('int_bool_0', true)).to eq(false)
      end

      it "reads 1 as 'true' when default is bool" do
        expect(config.fetch('int_bool_1', false)).to eq(true)
      end

      it "raises ArgumentError when default is bool but string can't be converted" do
        expect { config.fetch('string_val', false) }.to raise_error(ArgumentError)
      end

    end

    describe "#delete" do

      it "returns an instance without specified key" do
        expect(config.include?('mongo')).to be_true
        expect(config.delete('mongo').include?('mongo')).to be_false
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
        expect(config[:int_val]).to eq(63)
      end

    end

    describe "#delete" do

      it "returns an instance without specified key" do
        expect(config.include?('mongo')).to be_true
        expect(config.delete('mongo').include?('mongo')).to be_false
      end

    end

  end

  describe "#method_missing" do

    it "read an int value from YAML data" do
      expect(config.int_val).to eq(1234)
    end

    it "reads a boolean value from YAML data" do
      expect(config.bool_val).to equal(true)
    end

    it "reads a string value from YAML data" do
      expect(config.string_val).to eq('hithere')
    end

    it "reads an env val from YAML data and parses it" do
      expect(config.env_val).to eq(ENV['whereami'])
    end

    it "creates a new Config when reading a Hash" do
      expect(config.mongo).to be_instance_of(Lynr::Config)
    end

    it "does not return a Hash" do
      expect(config.mongo).to_not be_instance_of(Hash)
    end

    it "reads 'false' as string when not a query" do
      expect(config.str_bool_false).to eq('false')
    end

    it "reads 'false' as bool when a query" do
      expect(config.str_bool_false?).to equal(false)
    end

    it "reads 'true' as string when not a query" do
      expect(config.str_bool_true).to eq('true')
    end

    it "reads 'true' as bool when a query" do
      expect(config.str_bool_true?).to equal(true)
    end

  end

  describe "#respond_to_missing?" do

    [
      :mongo, :int_val, :bool_val, :false_val, :string_val, :env_val,
      :str_bool_false, :str_bool_true, :int_bool_0, :int_bool_1,
    ].each do |name|

      it "responds to #{name} from config" do
        expect(config.respond_to?(name.to_sym)).to be_true
      end

    end

  end

end
