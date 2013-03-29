require 'rspec/autorun'
require 'yaml'
require './lib/lynr/config'

describe Lynr::Config do

  before(:each) do
    ENV['whereami'] = 'test'
    @config = YAML.load_file("config/database.#{ENV['whereami']}.yaml")
  end

  let(:config_type) { 'database' }
  let(:config_env) { 'test' }
  let(:config) { Lynr::Config.new('database', 'test') }

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

  end

  describe ".[]" do

    it "reads an int value from YAML data and returns it" do
      expect(config['int_val']).to equal(1234)
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

  end

end
