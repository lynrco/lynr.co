require 'bcrypt'

module Quicklist; module Model;

  class Identity

    attr_reader :id
    attr_reader :email, :password

    def initialize(email, password, id=nil)
      @id = id
      @email = email
      @password = BCrypt::Password.create(password, :cost => 13)
    end

    def auth?(e, p)
      self == { email: e, password: p }
    end

    def view
      { email: @email, password: @password }
    end

    def ==(ident)
      if (ident.is_a? Hash)
        @email == ident[:email] && @password == ident[:password]
      else
        false
      end
    end

  end

end; end;
