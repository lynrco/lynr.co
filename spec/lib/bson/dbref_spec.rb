require 'rspec/autorun'

require 'bson'
require './lib/bson/dbref'

describe BSON::DBRef do

  describe "#==" do

    let(:ns) { 'dealers' }
    let(:id) { BSON::ObjectId('52aa41336dbe987fb5000002') }
    let(:ref) { BSON::DBRef.new(ns, id) }
    
    it "is false when given nil" do
      expect(ref).to_not eq(nil)
    end

    it "is false when given something other than `DBRef`" do
      expect(ref).to_not eq(BSON::ObjectId('52aa41336dbe987fb5000002'))
    end

    it "is false when given DBRef with different namespace" do
      expect(ref).to_not eq(BSON::DBRef.new('hi', BSON::ObjectId('52aa41336dbe987fb5000002')))
    end
    
    it "is false when given DBRef with different object_id" do
      expect(ref).to_not eq(BSON::DBRef.new('dealers', BSON::ObjectId('52aa41336dbe987fb5000001')))
    end

    it "is true when `DBRef#namespace` and `DBRef#object_id` return the same values" do
      expect(ref).to eq(BSON::DBRef.new('dealers', BSON::ObjectId('52aa41336dbe987fb5000002')))
    end

  end

end
