require './spec/spec_helper'

require './lib/lynr/cache'

shared_examples Lynr::Cache do

  let(:cache) { described_class.new }

  before(:each) { cache.write(:baz, 'crumbs') }

  after(:each) { cache.clear }

  describe "#initialize" do

    it "provides an object which responds to #available?" do
      expect(cache.respond_to?(:available?)).to be_true
    end

    it "provides an object which responds to #get" do
      expect(cache.respond_to?(:get)).to be_true
    end

    it "provides an object which responds to #set" do
      expect(cache.respond_to?(:set)).to be_true
    end

    it "provides an object which responds to #del" do
      expect(cache.respond_to?(:del)).to be_true
    end

    it "provides an object which responds to #read" do
      expect(cache.respond_to?(:read)).to be_true
    end

    it "provides an object which responds to #write" do
      expect(cache.respond_to?(:write)).to be_true
    end

    it "provides an object which responds to #remove" do
      expect(cache.respond_to?(:remove)).to be_true
    end

    it "provides an object which responds to #include?" do
      expect(cache.respond_to?(:include?)).to be_true
    end

    it "provides an object which responds to #clear" do
      expect(cache.respond_to?(:clear)).to be_true
    end

  end

  describe "#clear" do

    it "removes all keys" do
      cache.set(:foo, 'bar')
      cache.set(:bar, 'baz')
      cache.clear
      expect(cache.include?(:foo)).to be_false
      expect(cache.include?(:bar)).to be_false
    end

  end

  describe "#include?" do

    it "is true if a key has been set" do
      cache.set(:foo, "bar")
      expect(cache.include?(:foo)).to be_true
    end

    it "is false if a key has not been set" do
      expect(cache.include?(:foo)).to be_false
    end

  end

  describe "#write" do

    it "creates a key that does not exist" do
      expect(cache.include?(:foo)).to be_false
      cache.write(:foo, 'bar')
      expect(cache.read(:foo)).to eq('bar')
    end

    it "overwrites a key that does exist" do
      expect(cache.include?(:baz)).to be_true
      cache.write(:baz, 'NEWBAR')
      expect(cache.read(:foo)).to eq('NEWBAR')
    end

  end

  describe "#read" do

    it "retrieves a key that does exist" do
      expect(cache.read(:baz)).to eq('crumbs')
    end

    it "is nil if a key does not exist and no default is provided" do
      expect(cache.include?(:foo)).to be_false
      expect(cache.read(:foo)).to be_nil
    end

    it "is the default if a key does not exist and a default is provided" do
      expect(cache.include?(:foo)).to be_false
      expect(cache.read(:foo, 'bumper')).to eq('bumper')
    end

  end

  describe "#remove" do

    it "deletes a key that does exist"

    it "does nothing to a key that does not exist"

  end

end
