require 'rspec/autorun'
require_relative '../../../lib/quicklist/model/identity'

describe Quicklist::Model::Identity do

  before(:all) do
    @email = 'bryan@quicklist.it'
    @password = 'this is a fake password'
    @ident = Quicklist::Model::Identity.new(@email, @password)
    @valid = { email: @email, password: @password }
  end

  it "can be compared to a Hash with email/password" do
    (@ident == @valid).should be_true
  end

  it "has an auth? method to check email/password" do
    @ident.auth?(@valid[:email], @valid[:password]).should be_true
  end

  it "fails auth? on invalid password" do
    @ident.auth?(@valid[:email], 'this is not my password').should be_false
  end

  it "has a view of it's data properties" do
    view = @ident.view
    view.keys.should include(:email, :password)
    view.values.should include(@email)
  end

  it "can be created from an existing password hash" do
    pass = BCrypt::Password.create('this is a fake password')
    tmp_ident = Quicklist::Model::Identity.new(@email, pass)
    (tmp_ident == @valid).should be_true
    tmp_ident.auth?(@valid[:email], 'invalid password').should be_false
  end

end
