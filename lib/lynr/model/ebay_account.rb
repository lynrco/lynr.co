require 'time'

require './lib/lynr/model/base'

module Lynr::Model

  class EbayAccount
  
    include Lynr::Model::Base

    attr_reader :expires, :session, :token

    def initialize(data={})
      @expires = data.fetch('expires', default=DateTime.parse('Feb 11 13:32:16 2013 -0500'))
      @session = data.fetch('session', default="")
      @token = data.fetch('token', default="")
    end

    def view
      { 'expires' => expires, 'session' => session, 'token' => token, }
    end

    def self.inflate(record)
      data = record || {}
      Lynr::Model::EbayAccount.new(data)
    end

    private

    def equality_fields
      [:expires, :token]
    end

  end

end
