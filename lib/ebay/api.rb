require 'rest-client'
require 'libxml'

require './lib/ebay/session'
require './lib/lynr'
require './lib/lynr/converter/libxml_helper'

module Ebay

  class Api

    def self.sign_in_url
      
    end

    def self.session
      url = 'https://api.sandbox.ebay.com/ws/api.dll'
      config = Lynr.config('app').ebay
      data = <<EOF
<?xml version="1.0" encoding="utf-8"?>
<GetSessionIDRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <RuName>#{config.runame}</RuName>
</GetSessionIDRequest>
EOF
      Session.new(send(url, data))
    end

    def self.send(url, data)
      config = Lynr.config('app').ebay
      headers = {
        'Content-type' => 'application/x-www-form-urlencoded',
        'Accept' => '*/*',
        'Cache-Control' => 'no-cache',
        'Pragma' => 'no-cache',
        'X-EBAY-API-APP-NAME' => config.appid,
        'X-EBAY-API-DEV-NAME' => config.devid,
        'X-EBAY-API-CERT-NAME' => config.certid,
        'X-EBAY-API-CALL-NAME' => 'GetSessionID',
        'X-EBAY-API-SITEID' => '0',
        'X-EBAY-API-COMPATIBILITY-LEVEL' => '849',
        'Content-length' => data.length,
      }
      RestClient.post url, data, headers
    end

  end

end
