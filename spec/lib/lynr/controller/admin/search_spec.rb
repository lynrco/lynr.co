require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/controller/base_specs_shared'

require './lib/lynr/controller/admin/search'

describe Lynr::Controller::Admin::Search do

  include_context "spec/support/RouteHelper"

  let(:path) { '/admin/:slug/search' }
  let(:env_opts) { { 'rack.session' => { 'dealer_id' => saved_empty_dealership.id } } }

  before(:each) do
    Lynr::Controller::Admin::Search.any_instance.stub(:search) do |dealership, query|
      {
        "took" => 2,
        "timed_out" => false,
        "_shards" => { "total" => 5,"successful" => 5,"failed" => 0 },
        "hits" => {
          "total" => 1,
          "max_score" => 0.2360665,
          "hits" => [
            {
              "_index" => "vehicles",
              "_type" => "Lynr::Model::Vehicle",
              "_id" => "532cde8e6dbe98f23b000001",
              "_score" => 0.2360665,
              "_source" => {
                "condition" => "2",
                "dealership" => "52d749ae6dbe98c586000001",
                "mileage" => "55437",
                "mpg" => { "city" => "18","highway" => "24" },
                "notes" => "",
                "price" => "12980",
                "vin" => {
                  "number" => nil,
                  "doors" => "2",
                  "drivetrain" => "RWD",
                  "ext_color" => "Blue",
                  "fuel" => "G",
                  "int_color" => "Tan",
                  "make" => "Ford",
                  "model" => "Mustang",
                  "transmission" => "A",
                  "year" => "2008"
                },
                "created_at" => "2014-03-22 00:51:26 UTC",
                "updated_at" => "2014-03-22 00:51:26 UTC",
                "deleted_at" => nil
              }
            }
          ]
        }
      }
    end
  end

  after(:each) do
    MongoHelpers.empty! if MongoHelpers.dao.active?
  end

  context "/admin/:slug/search?q=Ford", :route => :extend, :if => (MongoHelpers.connected?) do

    include ModelHelper

    let(:uri) { "/admin/#{saved_empty_dealership.id.to_s}/search?q=Ford" }

    it_behaves_like "Lynr::Controller::Base#valid_request"

  end

end
