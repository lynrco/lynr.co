require 'bcrypt'

module Lynr; module Model;

  class Identity

    DEFAULT_COST = 13

    attr_reader :email, :password

    def initialize(email, password)
      @email = email
      begin
        @password = BCrypt::Password.new(password)
      rescue BCrypt::Errors::InvalidHash
        @password = BCrypt::Password.create(password, :cost => DEFAULT_COST)
      end
    end

    def auth?(e, p)
      @email == e && @password == p
    end

    def view
      { 'email' => @email, 'password' => @password }
    end

    def ==(ident)
      if (ident.is_a?(Hash) && ident.keys.include?(:email) && ident.keys.include?(:password))
        self.auth?(ident[:email], ident[:password])
      elsif (ident.is_a?(Hash) && ident.keys.include?('email') && ident.keys.include?('password'))
        self.auth?(ident['email'], ident['password'])
      elsif (ident.is_a?(Identity))
        ident.email == email && ident.password.to_s == password.to_s
      else
        false
      end
    end

    def self.inflate(record)
      raise ArgumentError.new("Can't inflate a nil record") if record.nil?
      Lynr::Model::Identity.new(record['email'], record['password'])
    end

  end

end; end;
