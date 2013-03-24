require 'rspec/autorun'
require './lib/lynr/model/identity'

describe Lynr::Model::Identity do

  before(:all) do
    @email = 'bryan@lynr.co'
    @password = 'this is a fake password'
    @ident = Lynr::Model::Identity.new(@email, @password)
    @valid = { email: @email, password: @password }
  end

  describe "#initialize" do

    it "can be created from an existing password hash" do
      pass = BCrypt::Password.create('this is a fake password')
      tmp_ident = Lynr::Model::Identity.new(@email, pass)
      (tmp_ident == @valid).should be_true
      tmp_ident.auth?(@valid[:email], 'invalid password').should be_false
    end

  end

  describe "#auth?" do

    it "has an auth? method to check email/password" do
      @ident.auth?(@valid[:email], @valid[:password]).should be_true
    end

    it "fails auth? on invalid password" do
      @ident.auth?(@valid[:email], 'this is not my password').should be_false
    end

  end

  describe "#view" do

    it "has a view of it's data properties" do
      view = @ident.view
      view.keys.should include(:email, :password)
      view.values.should include(@email)
    end

  end

  describe "#==" do

    it "compares to a Hash with email/password" do
      (@ident == @valid).should be_true
    end

  end

  describe ".inflate" do

    it "creates auth? capable instances from properties" do
      props = @ident.view
      inflated = Lynr::Model::Identity.inflate(props)
      expect(inflated.auth?(@valid[:email], @valid[:password])).to be_true
    end

    it "raises an error when given nil" do
      expect { Lynr::Model::Identity.inflate(nil) }.to raise_error(ArgumentError)
    end

  end

end
