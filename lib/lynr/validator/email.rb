require 'resolv'

module Lynr::Validator

  # # `Lynr::Validator::Email`
  #
  # Collect together the logic used to validate email addresses. Requires including
  # class to have a `#dao` method which returns an instance capable which responds to
  # the `:account_exists?` message. This message receiver should determine if there
  # is already an account identified by the provided email address.
  #
  module Email

    # ## `Lynr::Validator::Email#error_for_email(dao, email)`
    #
    # Given `email` return an error if it isn't valid or is already taken, `nil`
    # otherwise. `dao` must be a class with an `#account_exists?(email)` method
    # which returns true if `email` is already assigned to an account, false
    # otherwise.
    #
    def error_for_email(dao, email)
      if (!is_valid_email?(email))
        "Check your email address."
      elsif (dao.account_exists?(email))
        "#{email} is already taken."
      else
        nil
      end
    end

    # ## `Lynr::Validator::Email#is_valid_email?(email)
    #
    # Check if provided `email` is valid.
    #
    def is_valid_email?(email)
      parts = email.partition('@')
      local = parts[0]
      domain = parts[2]
      !((email.index('@').nil?) || # no at sign
        is_valid_local?(local) ||
        is_valid_domain?(domain)) # domain part has two consecutive dots
    end

    # ## `Lynr::Validator::Email#is_valid_domain?(domain)`
    #
    # Checks that the domain part of an email address follows the rules.
    #
    def is_valid_domain?(domain)
      (domain.length < 1 || domain.length > 255) || # domain part length exceeded
      (domain.index(%r(^[A-Za-z0-9\-\.]+$)) != 0) || # invalid character in domain part
      (!domain.index(%r(\.\.)).nil?) # domain part has two consecutive dots
    end

    # ## `Lynr::Validator::Email#is_valid_local?(domain)`
    #
    # Checks that the local part of an email address follows the rules.
    #
    def is_valid_local?(local)
      (local.length < 1 || local.length > 64) || # local part length exceeded
      local.start_with?(".") || # local part starts with '.'
      local.end_with?(".") || # local part ends with '.'
      (!local.index(%r(\.\.)).nil?) # local part has two consecutive dots
    end

    # ## `Lynr::Validator::Email#is_valid_tld?(domain)`
    #
    # Check if domain is valid by checking it has MX or A records defined.
    #
    def is_valid_tld?(domain)
      mx_records = []
      a_records = []
      Resolv::DNS.open do |dns|
        mx_records = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
        a_records = dns.getresources(domain, Resolv::DNS::Resource::IN::A)
      end
      mx_records.size > 0 || a_records.size > 0
    end

  end

end
