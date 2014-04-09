require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/subscription'

describe Lynr::Model::Subscription do

  subject(:subscription) { Lynr::Model::Subscription.new(plan: 'lynr_alpha', status: status) }

  context "with status=inactive" do

    let(:status) { 'inactive' }

    describe "#active?" do
      it { expect(subscription.active?).to be_false }
    end

    describe "#delinquent?" do
      it { expect(subscription.delinquent?).to be_false }
    end

    describe "#canceled?" do
      it { expect(subscription.canceled?).to be_false }
    end

  end

  context "with status=trialing" do

    let(:status) { 'trialing' }

    describe "#active?" do
      it { expect(subscription.active?).to be_true }
    end

    describe "#delinquent?" do
      it { expect(subscription.delinquent?).to be_false }
    end

    describe "#canceled?" do
      it { expect(subscription.canceled?).to be_false }
    end

  end

  context "with status=active" do

    let(:status) { 'active' }

    describe "#active?" do
      it { expect(subscription.active?).to be_true }
    end

    describe "#delinquent?" do
      it { expect(subscription.delinquent?).to be_false }
    end

    describe "#canceled?" do
      it { expect(subscription.canceled?).to be_false }
    end

  end

  context "with status=past_due" do

    let(:status) { 'past_due' }

    describe "#active?" do
      it { expect(subscription.active?).to be_false }
    end

    describe "#delinquent?" do
      it { expect(subscription.delinquent?).to be_true }
    end

    describe "#canceled?" do
      it { expect(subscription.canceled?).to be_false }
    end

  end

  context "with status=canceled" do

    let(:status) { 'canceled' }

    describe "#active?" do
      it { expect(subscription.active?).to be_false }
    end

    describe "#delinquent?" do
      it { expect(subscription.delinquent?).to be_false }
    end

    describe "#canceled?" do
      it { expect(subscription.canceled?).to be_true }
    end

  end

  context "with status=unpaid" do

    let(:status) { 'unpaid' }

    describe "#active?" do
      it { expect(subscription.active?).to be_false }
    end

    describe "#delinquent?" do
      it { expect(subscription.delinquent?).to be_false }
    end

    describe "#canceled?" do
      it { expect(subscription.canceled?).to be_true }
    end

  end

  describe "#==" do

    let(:status) { 'active' }

    it "is true if plan and status are the same" do
      sub = Lynr::Model::Subscription.new(plan: 'lynr_alpha', status: status)
      expect(subscription).to eq(sub)
    end

    it "is false if plan is equal and status isn't" do
      sub = Lynr::Model::Subscription.new(plan: 'lynr_alpha', status: 'inactive')
      expect(subscription).to_not eq(sub)
    end

    it "is false if plan is not equal and status is" do
      sub = Lynr::Model::Subscription.new(plan: 'lynr_hi', status: status)
      expect(subscription).to_not eq(sub)
    end

  end

  describe ".inflate" do

    let(:props) { { plan: 'lynr_plan', status: 'active' } }

    it "is the same as .new" do
      expect(Lynr::Model::Subscription.new(props)).to eq(Lynr::Model::Subscription.inflate(props))
    end

  end

end
