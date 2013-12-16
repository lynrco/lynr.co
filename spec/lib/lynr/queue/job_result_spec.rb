require 'rspec/autorun'
require './spec/spec_helper'

describe Lynr::Queue::JobResult do

  shared_examples_for "Success.and(Success)" do

    it "does not requeue" do
      expect(result.requeue?).to be_false
    end

    it "has succeeded" do
      expect(result.success?).to be_true
    end

  end

  shared_examples_for "Success.and(Failure[requeue])" do

    it "does requeue" do
      expect(result.requeue?).to be_true
    end

    it "has not succeeded" do
      expect(result.success?).to be_false
    end

    it "has failure message" do
      expect(result.message).to eq(failure_requeue.message)
    end

  end

  shared_examples_for "Success.and(Failure[no_requeue])" do

    it "does requeue" do
      expect(result.requeue?).to be_false
    end

    it "has not succeeded" do
      expect(result.success?).to be_false
    end

    it "has failure message" do
      expect(result.message).to eq(failure_no_requeue.message)
    end

  end

  shared_examples_for "Failure[requeue].and(Failure[no_requeue])" do

    it "does requeue" do
      expect(result.requeue?).to be_true
    end

    it "has not succeeded" do
      expect(result.success?).to be_false
    end

    it "has first failure message" do
      expect(result.message).to eq(failure_requeue.message)
    end

  end

  shared_examples_for "Failure[no_requeue].and(Failure[requeue])" do

    it "does requeue" do
      expect(result.requeue?).to be_false
    end

    it "has not succeeded" do
      expect(result.success?).to be_false
    end

    it "has first failure message" do
      expect(result.message).to eq(failure_no_requeue.message)
    end

  end

  describe "#and" do

    let(:success) { Lynr::Queue::JobResult.new }
    let(:failure_requeue) { Lynr::Queue::JobResult.new('let(:failure_requeue)', false) }
    let(:failure_no_requeue) { Lynr::Queue::JobResult.new('let(:failure_no_requeue)', false, :norequeue) }

    context "Success.and(Success)" do

      let(:result) { success.and(Lynr::Queue::JobResult.new) }

      it_behaves_like "Success.and(Success)"

    end

    context "Success.and(Failure[requeue])" do

      let(:result) { success.and(failure_requeue) }

      it_behaves_like "Success.and(Failure[requeue])"

    end

    context "Success.and(Failure[no_requeue])" do

      let(:result) { success.and(failure_no_requeue) }

      it_behaves_like "Success.and(Failure[no_requeue])"

    end

    context "Failure[requeue].and(Failure[no_requeue])" do

      let(:result) { failure_requeue.and(failure_no_requeue) }

      it_behaves_like "Failure[requeue].and(Failure[no_requeue])"

    end

    context "Failure[no_requeue].and(Failure[requeue])" do

      let(:result) { failure_no_requeue.and(failure_requeue) }

      it_behaves_like "Failure[no_requeue].and(Failure[requeue])"

    end

  end

  describe "#requeue?" do

    it "is false if created with succeeded=true" do
      jr = Lynr::Queue::JobResult.new(message="", succeeded=true)
      expect(jr.requeue?).to be_false
    end

    it "is true if created with requeue=true" do
      jr = Lynr::Queue::JobResult.new(message="", succeeded=false, requeue=true)
      expect(jr.requeue?).to be_true
    end

    it "is true if created with requeue=:requeue" do
      jr = Lynr::Queue::JobResult.new(message="", succeeded=false, requeue=:requeue)
      expect(jr.requeue?).to be_true
    end

    it "is false if created with requeue parameter equal to anything other than `true` or `:requeue`" do
      jr = Lynr::Queue::JobResult.new(message="", succeeded=false, requeue=:norequeue)
      expect(jr.requeue?).to be_false
    end

  end

  describe "#success?" do

    it "is true if created with succeeded equal to any truthy value" do
      jr = Lynr::Queue::JobResult.new(message="", succeeded=true)
      expect(jr.success?).to be_true
      jr = Lynr::Queue::JobResult.new(message="", succeeded=:yay)
      expect(jr.success?).to be_true
    end

    it "is false if created with succeeded equal to any falsey value" do
      jr = Lynr::Queue::JobResult.new(message="", succeeded=false)
      expect(jr.success?).to be_false
      jr = Lynr::Queue::JobResult.new(message="", succeeded=nil)
      expect(jr.success?).to be_false
    end

  end

  describe "#then" do

    let(:success) { Lynr::Queue::JobResult.new }
    let(:failure_requeue) { Lynr::Queue::JobResult.new('let(:failure_requeue)', false) }
    let(:failure_no_requeue) { Lynr::Queue::JobResult.new('let(:failure_no_requeue)', false, :norequeue) }

    context "Success.then { Success }" do

      let(:result) { success.then { Lynr::Queue::JobResult.new } }

      it_behaves_like "Success.and(Success)"

    end

    context "Success.and(Failure[requeue])" do

      let(:result) { success.then { failure_requeue } }

      it_behaves_like "Success.and(Failure[requeue])"

    end

    context "Success.and(Failure[no_requeue])" do

      let(:result) { success.then { failure_no_requeue } }

      it_behaves_like "Success.and(Failure[no_requeue])"

    end

    context "Failure[requeue].and(Failure[no_requeue])" do

      let(:result) { failure_requeue.then { failure_no_requeue } }

      it_behaves_like "Failure[requeue].and(Failure[no_requeue])"

    end

    context "Failure[no_requeue].and(Failure[requeue])" do

      let(:result) { failure_no_requeue.then { failure_requeue } }

      it_behaves_like "Failure[no_requeue].and(Failure[requeue])"

    end

  end

end
