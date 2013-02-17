require 'bcrypt'

module Quicklist

  module Model

    class Identity

      attr_reader :email, :password

      def initialize(email, password)
        @email = email
        @password = BCrypt::Password.create(password, :cost => 13)
      end

      def auth?(e, p)
        self == { email: e, password: p }
      end

      def view
        { email: @email }
      end

      def ==(ident)
        if (ident.is_a? Hash)
          self.email == ident[:email] && self.password == ident[:password]
        else
          false
        end
      end

    end

  end

end
