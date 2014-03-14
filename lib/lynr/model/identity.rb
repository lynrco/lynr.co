require 'bcrypt'

module Lynr; module Model;

  # # `Lynr::Model::Identity`
  #
  # Represent an account by email and an encrypted password. Passwords are encrypted
  # using BCrypt and stored that way.
  #
  class Identity

    DEFAULT_COST = 13

    attr_reader :email, :password

    # ## `Identity.new(email, password)`
    #
    # Create a new `Identity` instance from `email` and `password`. `password`
    # is assumed to be an encrypted string and so is passed to `BCrypt::Password.new`
    # but that raises an `InvalidHash` error assume `password` is plain text and
    # encrypt it to create the `Identity`.
    #
    def initialize(email, password)
      @email = email
      begin
        @password = BCrypt::Password.new(password)
      rescue BCrypt::Errors::InvalidHash
        @password = BCrypt::Password.create(password, :cost => DEFAULT_COST)
      end
    end

    # ## `Identity#auth?(e, p)`
    #
    # Compare `@email` and `@password` to `e` and `p` respectively to determine
    # if they are valid credentials.
    #
    def auth?(e, p)
      @email == e && @password == p
    end

    def view
      { 'email' => @email, 'password' => @password.to_s }
    end

    # ## `Identity#==(ident)`
    #
    # Determine equality by determining if `ident` could be used to authenticate
    # with this instance.
    #
    def ==(ident)
      if (ident.is_a?(Hash))
        self.auth?(
          ident.fetch(:email, ident.fetch('email', nil)),
          ident.fetch(:password, ident.fetch('password', nil))
        )
      elsif (ident.is_a?(Identity))
        ident.email == email && ident.password.to_s == password.to_s
      else
        false
      end
    end

    # ## `Identity.inflate(record)`
    #
    # Create a new `Identity` instance from a `Hash` representing a database
    # record.
    #
    def self.inflate(record)
      raise ArgumentError.new("Can't inflate a nil record") if record.nil?
      Lynr::Model::Identity.new(record['email'], record['password'])
    end

  end

end; end;
