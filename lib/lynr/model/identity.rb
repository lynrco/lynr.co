require 'bcrypt'

module Lynr; module Model;

  class Identity

    attr_reader :email, :password

    def initialize(email, password)
      @email = email
      begin
        @password = BCrypt::Password.new(password)
      rescue BCrypt::Errors::InvalidHash
        @password = BCrypt::Password.create(password, :cost => 13)
      end
    end

    def auth?(e, p)
      @email == e && @password == p
    end

    def view
      { email: @email, password: @password }
    end

    def ==(ident)
      if (ident.is_a? Hash)
        self.auth?(ident[:email], ident[:password])
      else
        false
      end
    end

    def self.inflate(record)
      raise ArgumentError.new("Can't inflate a nil record") if record.nil?
      Lynr::Model::Identity.new(record[:email], record[:password])
    end

  end

end; end;
