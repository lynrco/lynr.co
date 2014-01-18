require 'yaml'

require './lib/ebay'
require './lib/lynr/cache'

module Lynr::Controller

  # # `Lynr::Controller::Ebay`
  #
  # Resource/Controller class to handle redirecting the customer to eBay for
  # authentication.
  #
  class Ebay < Lynr::Controller::Base

    get  '/auth/ebay', :get

    # ## `Ebay#get(req)`
    #
    # Send the customer to the eBay authentication endpoint.
    #
    def get(req)
      # TODO: check that we aren't already connected
      session = ::Ebay::Api.session
      Lynr::Cache.mongo.set("#{req.session['dealer_id']}_ebay_session", YAML.dump(session))
      redirect ::Ebay::Api.sign_in_url(session)
    end

    module Helpers

      PARAM = 'eBay_connect'

      # ## `Ebay::Helpers#clear_session(req)`
      #
      # Clear the `Ebay::Session` tied to `req` out of the cache.
      def clear_ebay_session(req)
        Lynr::Cache.mongo.del("#{req.session['dealer_id']}_ebay_session")
      end

      # ## `Ebay::Helpers#get_session(req)`
      #
      # Get the `Ebay::Session` tied to `req` from the cache.
      #
      def get_ebay_session(req)
        session_data = Lynr::Cache.mongo.get("#{req.session['dealer_id']}_ebay_session")
        YAML.load(session_data)
      end

      # ## `Ebay::Helpers.connect_message(req)`
      #
      # Get the messages associated with the eBay connection code in `req#params`
      #
      def self.connect_message(req)
        case req.params[PARAM]
        when 'success' then "Successfully connected to eBay"
        when 'failure' then "eBay connection declined. We can't list on your behalf without it."
        when 'token_invalid' then "Unable to establish connection to eBay. Please try again."
        end
      end

    end

  end

end
