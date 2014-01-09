require 'yaml'

require './lib/ebay'
require './lib/lynr/cache'

module Lynr::Controller

  class Ebay::Callback < Lynr::Controller::Base

    get  '/auth/ebay/callback', :get

    def initialize
      super
      @title = "Callback Success"
    end

    def get(req)
      data = Lynr::Cache.mongo.get("#{req.session['dealer_id']}_ebay_session")
      session = YAML.load(data)
      @token = ::Ebay::Api.token(session)
      Lynr::Cache.mongo.set("#{req.session['dealer_id']}_ebay_token", YAML.dump(@token))
      render 'auth/ebay/callback.erb', layout: 'default.erb'
    end

  end

end
