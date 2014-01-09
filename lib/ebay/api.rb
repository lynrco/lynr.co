require 'cgi'
require 'libxml'
require 'rest-client'

require './lib/ebay/session'
require './lib/lynr'
require './lib/lynr/logging'
require './lib/lynr/converter/libxml_helper'

module Ebay

  class Api

    extend Lynr::Logging

    SANDBOX = 'https://api.sandbox.ebay.com/ws/api.dll'

    def self.sign_in_url(session)
      config = Lynr.config('app').ebay
      "https://signin.sandbox.ebay.com/ws/eBayISAPI.dll?SignIn&RuName=#{config.runame}&SessID=#{CGI.escape(session.id)}"
    end

    def self.session
      config = Lynr.config('app').ebay
      data = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<GetSessionIDRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <RuName>#{config.runame}</RuName>
</GetSessionIDRequest>
      EOF
      Session.new(send('GetSessionID', SANDBOX, data))
    end

    def self.token(session)
      data = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<FetchTokenRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <SessionID>#{session.id}</SessionID>
</FetchTokenRequest>
      EOF
      Token.new(send('FetchToken', SANDBOX, data))
    end

    def self.send(method, url, data)
      config = Lynr.config('app').ebay
      headers = {
        'Content-type' => 'application/x-www-form-urlencoded',
        'Accept' => '*/*',
        'Cache-Control' => 'no-cache',
        'Pragma' => 'no-cache',
        'X-EBAY-API-APP-NAME' => config.appid,
        'X-EBAY-API-DEV-NAME' => config.devid,
        'X-EBAY-API-CERT-NAME' => config.certid,
        'X-EBAY-API-CALL-NAME' => method,
        'X-EBAY-API-SITEID' => '0',
        'X-EBAY-API-COMPATIBILITY-LEVEL' => '849',
        'Content-length' => data.length,
      }
      response = RestClient.post url, data, headers
      log.debug("type=record.external.ebay url=#{url} data=#{data} headers=#{headers} response=#{response}")
      response
    end

  end

end
