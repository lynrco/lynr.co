module Lynr::Validator

  # # `Lynr::Validator::Password`
  #
  # Contain the logic for password validation into this module.
  #
  module Password

    # ## `Lynr::Validator::Password#error_for_password(password, confirm)`
    #
    # Return `nil` if `password` is valid and matches `confirm`, otherwise return
    # a String with an appropriate error message
    #
    def error_for_passwords(password, confirm)
      if (!is_valid_password?(password))
        "Your password must be at least 3 characters."
      elsif (password != confirm)
        "Your passwords don't match."
      else
        nil
      end
    end

    # ## `Lynr::Validator::Helpers#is_valid_password?(password)`
    #
    # Check `password` against validation rules, presently only that the password
    # is at least four (4) characters.
    #
    def is_valid_password?(password)
      password.length > 3
    end

  end

end
