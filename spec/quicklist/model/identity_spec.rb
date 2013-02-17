require 'rspec/autorun'
require_relative '../../../lib/quicklist/model/identity'

describe Quicklist::Model::Identity do

  before(:all) do
    @ident = Quicklist::Model::Identity.new('bryan@quicklist.it', 'this is a fake password')
    @valid = { email: 'bryan@quicklist.it', password: 'this is a fake password' }
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

end
