require './spec/spec_helper'

require './lib/lynr/controller/base'

shared_examples "Lynr::Controller::Base#valid_request" do

  describe "route.call(req)" do

    let(:response) { route.call(env) }

    it "is an Array" do
      expect(response).to be_instance_of(Array)
    end

    it "is a finished Rack::Response (length 3 array)" do
      expect(response.length).to eq(3)
    end

    it "has headers in second position" do
      expect(response[1]).to be_instance_of(Rack::Utils::HeaderHash)
      expect(response[1].is_a?(Hash)).to be_true
    end

    it "has body in third position" do
      expect(response[2]).to be_instance_of(Rack::BodyProxy)
    end

    it "is a 200 response" do
      expect(response[0]).to eq(200)
    end

  end

end
