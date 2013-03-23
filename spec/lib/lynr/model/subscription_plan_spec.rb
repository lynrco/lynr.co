require 'rspec/autorun'
require './lib/lynr/model/subscription_plan'

describe Lynr::Model::SubscriptionPlan do

  let(:record) {
    { id: 'gold', amount: 2000, interval: 'month', name: 'Amazing Gold Plan', currency: 'usd', trial_period_days: 30 }
  }

  describe "#initialize" do

    let(:data) { record.dup }
    let(:id) { data.delete(:id) }

    it "should succeed with correct data" do
      expect(Lynr::Model::SubscriptionPlan.new(data, id)).to eq(record)
    end

    it "raises an error when amount is less than 0" do
      data[:amount] = -1
      expect { Lynr::Model::SubscriptionPlan.new(data, id) }.to raise_error(ArgumentError)
    end

    it "raises an error when name isn't provided" do
      data.delete(:name)
      expect { Lynr::Model::SubscriptionPlan.new(data, id) }.to raise_error(ArgumentError)
    end

    it "raises an error when id is nil" do
      expect { Lynr::Model::SubscriptionPlan.new(data, nil) }.to raise_error(ArgumentError)
    end

  end

  describe ".inflate" do

    let(:plan) { Lynr::Model::SubscriptionPlan.inflate(record) }

    it "matches the provided record" do
      expect(plan == record).to be_true
    end

  end

end
