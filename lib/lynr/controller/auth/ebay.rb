require 'yaml'

require './lib/ebay'
require './lib/lynr/cache'

module Lynr::Controller

  class Ebay < Lynr::Controller::Base

    get  '/auth/ebay', :get

    def get(req)
      session = ::Ebay::Api.session
      Lynr::Cache.mongo.set("#{req.session['dealer_id']}_ebay_session", YAML.dump(session))
      redirect ::Ebay::Api.sign_in_url(session)
    end

  end

end
