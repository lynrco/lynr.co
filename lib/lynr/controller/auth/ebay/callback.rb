require 'yaml'

require './lib/ebay'
require './lib/lynr/cache'
require './lib/lynr/model/ebay_account'

module Lynr::Controller

  # # `Lynr::Controller::Ebay::Callback`
  #
  # Resource/Controller class to handle the case where authentication with eBay
  # succeeds.
  #
  class Ebay::Callback < Lynr::Controller::Base

    get  '/auth/ebay/callback', :get

    def initialize
      super
      @title = "Callback Success"
    end

    def get(req)
      session_data = Lynr::Cache.mongo.get("#{req.session['dealer_id']}_ebay_session")
      session = YAML.load(session_data)
      token = ::Ebay::Api.token(session)
      # TODO: Check `token` is valid
      @account = Lynr::Model::EbayAccount.new(
        'expires' => token.expires, 'token' => token.id, 'session' => session.id,
      )
      Lynr::Cache.mongo.set("#{req.session['dealer_id']}_ebay_token", YAML.dump(token))
      render 'auth/ebay/callback.erb', layout: 'default.erb'
    end

  end

end
