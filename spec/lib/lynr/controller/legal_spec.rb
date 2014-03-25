require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/legal'

describe Lynr::Controller::Legal do

  include_context "spec/support/RouteHelper"

  let(:markdown) {
    path = ::File.join(Lynr.root, "public/legal/#{subject.version(req)}/#{subject.type(req)}.md")
    ::File.read(path)
  }
  let(:response) { subject.get(req) }

  before(:each) do
    Lynr::Controller::Legal.any_instance.stub(:config) do
      Lynr::Config.new(nil, nil, {
        'current' => '2014-03-12',
      })
    end
  end

  shared_examples "valid request" do

    describe "#markdown" do

      it "reads from `#version`/`#type`.md" do
        expect(subject.markdown(req)).to eq(markdown)
      end

    end

    describe "#document" do

      it "is a Kramdown::Document" do
        expect(subject.document(req)).to be_instance_of(Kramdown::Document)
      end

    end

    describe "#get" do

      it "is a Rack::Response" do
        expect(response).to be_instance_of(Rack::Response)
      end

      it "is a 200 response" do
        expect(response.status).to eq(200)
      end

    end

    it_behaves_like "Lynr::Controller::Base#valid_request"

  end

  shared_examples "invalid request" do

    describe "#get" do

      it "raises a NotFoundError" do
        expect { subject.get(req) }.to raise_error(Sly::NotFoundError)
      end

    end

  end

  context "/legal" do

    let(:uri) { '/legal' }
    let(:path) { '/legal' }

    describe "#type" do

      it "defaults to 'terms' when not provided" do
        expect(subject.type(req)).to eq('terms')
      end

    end

    describe "#version" do

      it "defaults to `config.current` when not provided" do
        expect(subject.version(req)).to eq(subject.config.current)
      end

    end

    describe "#header" do

      it "is read from document" do
        expect(subject.header(req).options[:raw_text]).to eq('Lynr Terms of Service')
      end

    end

    it_behaves_like "valid request"

  end

  context "/legal/terms" do

    let(:uri) { '/legal/terms' }
    let(:path) { '/legal/:type' }

    describe "#type" do

      it "is 'terms' when provided" do
        expect(subject.type(req)).to eq('terms')
      end

    end

    describe "#version" do

      it "defaults to `config.current` when not provided" do
        expect(subject.version(req)).to eq(subject.config.current)
      end

    end

    describe "#header" do

      it "is read from document" do
        expect(subject.header(req).options[:raw_text]).to eq('Lynr Terms of Service')
      end

    end

    it_behaves_like "valid request"

  end

  context "/legal/privacy" do

    let(:uri) { '/legal/privacy' }
    let(:path) { '/legal/:type' }

    describe "#type" do

      it "is 'privacy' when it is in the uri" do
        expect(subject.type(req)).to eq('privacy')
      end

    end

    describe "#version" do

      it "defaults to `config.current` when not provided" do
        expect(subject.version(req)).to eq(subject.config.current)
      end

    end

    describe "#header" do

      it "is read from document" do
        expect(subject.header(req).options[:raw_text]).to eq('Lynr Privacy Policy')
      end

    end

    it_behaves_like "valid request"

  end

  context "/legal/2014-03-12/privacy" do

    before(:each) do
      Lynr::Controller::Legal.any_instance.stub(:config) do
        Lynr::Config.new(nil, nil, {
          'current' => '2014-03-11',
        })
      end
    end

    let(:uri) { '/legal/2014-03-12/privacy' }
    let(:path) { '/legal/:version/:type' }

    describe "#type" do

      it "is 'privacy' when it is in the uri" do
        expect(subject.type(req)).to eq('privacy')
      end

    end

    describe "#version" do

      it "is '2014-03-12' when in the uri" do
        expect(subject.version(req)).to eq('2014-03-12')
      end

      it "is not `config.current` when in the uri" do
        expect(subject.version(req)).to_not eq(subject.config.current)
      end

    end

    describe "#header" do

      it "is read from document" do
        expect(subject.header(req).options[:raw_text]).to eq('Lynr Privacy Policy')
      end

    end

    it_behaves_like "valid request"

  end

  context "/legal/not_a_doc" do

    let(:uri) { '/legal/not_a_doc' }
    let(:path) { '/legal/:type' }

    describe "#type" do

      it "is to 'not_a_doc' when provided" do
        expect(subject.type(req)).to eq('not_a_doc')
      end

    end

    describe "#version" do

      it "defaults to `config.current` when not provided" do
        expect(subject.version(req)).to eq(subject.config.current)
      end

    end

    it_behaves_like "invalid request"

  end

end
