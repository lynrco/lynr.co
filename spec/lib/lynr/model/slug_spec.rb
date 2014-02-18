require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/slug'

describe Lynr::Model::Slug do

  let(:id) { BSON::ObjectId.from_time(Time.now) }

  describe ".new" do

    it "uses the id if name is nil" do
      expect(Lynr::Model::Slug.new(nil, id)).to eq(id.to_s)
    end

    it "uses the id if name is blank" do
      expect(Lynr::Model::Slug.new("", id)).to eq(id.to_s)
    end

    it "slugifys the name if provided" do
      expect(Lynr::Model::Slug.new("hi there", id)).to eq('hi-there')
    end

  end

  describe "#slugify" do

    it "turns whitespace into hyphens" do
      expect(Lynr::Model::Slug.slugify("hi there")).to eq("hi-there")
    end

    it "turns percents into hyphens" do
      expect(Lynr::Model::Slug.slugify("hi there%chumperton")).to eq("hi-there-chumperton")
    end

    it "turns apostrophes into hyphens" do
      expect(Lynr::Model::Slug.slugify("hi there'chumperton")).to eq("hi-there-chumperton")
    end

  end

end
