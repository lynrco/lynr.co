require 'cgi'
require 'libxml'
require 'rest-client'

require './lib/ebay/session'
require './lib/ebay/token'
require './lib/lynr'
require './lib/lynr/logging'
require './lib/lynr/converter/libxml_helper'

module Ebay

  # # `Ebay::Api`
  #
  # The `Ebay::Api` class is used to collect class methods to interact with the eBay
  # API in a Ruby way, giving and receiving objects. Behind the scenes this class
  # transforms XML responses into `Ebay` classes which can be serialized an then
  # reconstituted.
  #
  class Api

    autoload :Response, './lib/ebay/api/response'

    extend Lynr::Logging

    # eBay API endpoint used for testing
    SANDBOX = 'https://api.sandbox.ebay.com/ws/api.dll'
    # eBay API endpoint for production
    PRODUCTION = 'https://api.ebay.com/ws/api.dll'

    # ## `Api.sign_in_url(session)`
    #
    # Takes an `Ebay::Session` instance and uses it to generate an oauth style URL
    # for the customer to be forwarded to in order to grant Lynr access to the customer's
    # eBay data.
    #
    def self.sign_in_url(session)
      config = Lynr.config('app').ebay
      query = "SignIn&RuName=#{config.runame}&SessID=#{CGI.escape(session.id)}"
      "https://signin.sandbox.ebay.com/ws/eBayISAPI.dll?#{query}"
    end

    # ## `Api.session`
    #
    # Request a session id from the eBay API. This session information must be tracked
    # in order to tie a series of requests to a customer. `.session` works by generating
    # an XML request to send to eBay and using the response from the API to create an
    # `Ebay::Session` instance which is returned.
    #
    def self.session
      config = Lynr.config('app').ebay
      data = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<GetSessionIDRequest xmlns="#{Ebay::NS}">
  <RuName>#{config.runame}</RuName>
</GetSessionIDRequest>
      EOF
      Session.new(send('GetSessionID', SANDBOX, data))
    end

    # ## `Api.token(session)`
    #
    # Request an authentication token from the eBay API for the provided `session`.
    # `session` must have been previously (and recently) requested by the customer
    # and is used to create an XML FetchTokenRequest which is sent to eBay and the
    # response is used to create an `Ebay::Token` instance which is returned. The `.token`
    # method must be called after the `session` has been authenticated by the customer at
    # the authentication endpoint provided by `.sign_in_url`.
    #
    def self.token(session)
      data = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<FetchTokenRequest xmlns="#{Ebay::NS}">
  <SessionID>#{session.id}</SessionID>
</FetchTokenRequest>
      EOF
      Token.new(send('FetchToken', SANDBOX, data))
    end

    private

    # ## `Api.send(method, url, data)`
    #
    # *Private* method used to interact with the eBay API. `.send` takes care of setting
    # up the request headers by inserting config values, `method` and provided `data`
    # appropriately and then POSTing the request to the eBay API endpoint provided in `url`.
    # The value of the response from the POST request is returned.
    #
    def self.send(method, url, data)
      config = Lynr.config('app').ebay
      headers = {
        'Accept' => '*/*',
        'Cache-Control' => 'no-cache',
        'Content-type' => 'text/xml',
        'Content-length' => data.length,
        'Pragma' => 'no-cache',
        'X-EBAY-API-APP-NAME' => config.appid,
        'X-EBAY-API-DEV-NAME' => config.devid,
        'X-EBAY-API-CERT-NAME' => config.certid,
        'X-EBAY-API-CALL-NAME' => method,
        'X-EBAY-API-SITEID' => '0',
        'X-EBAY-API-COMPATIBILITY-LEVEL' => '849',
      }
      res = RestClient.post url, data, headers
      log.debug("type=record.external.ebay url=#{url} data=#{data} headers=#{headers} response=#{res}")
      res
    end

  end

end
