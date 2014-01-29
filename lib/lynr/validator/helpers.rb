require 'resolv'

module Lynr; module Validator;

  # # `Lynr::Validator::Helpers`
  #
  # Validation methods for checking form input against specified rules.
  #
  module Helpers

    # ## `Lynr::Validator::Helpers#is_valid_email?(email)
    #
    # Check if provided `email` is valid.
    #
    def is_valid_email?(email)
      parts = email.partition('@')
      local = parts[0]
      domain = parts[2]
      valid = !((email.index('@').nil?) || # no at sign
                (local.length < 1 || local.length > 64) || # local part length exceeded
                (domain.length < 1 || domain.length > 255) || # domain part length exceeded
                local.start_with?(".") || # local part starts with '.'
                local.end_with?(".") || # local part ends with '.'
                (!local.index(%r(\.\.)).nil?) || # local part has two consecutive dots
                (domain.index(%r(^[A-Za-z0-9\-\.]+$)) != 0) || # invalid character in domain part
                (!domain.index(%r(\.\.)).nil?)) # domain part has two consecutive dots

      valid && is_valid_email_domain?(domain)
    end

    # ## `Lynr::Validator::Helpers#is_valid_email_domain?(domain)`
    #
    # Check if domain is valid by checking it has MX or A records defined.
    #
    def is_valid_email_domain?(domain)
      mx_records = []
      a_records = []
      Resolv::DNS.open do |dns|
        mx_records = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
        a_records = dns.getresources(domain, Resolv::DNS::Resource::IN::A)
      end
      mx_records.size > 0 || a_records.size > 0
    end

    # ## `Lynr::Validator::Helpers#validate_required(posted, fields)`
    #
    # Check that `posted` contains a non-nil, non-empty value for each key in `fields`.
    #
    def validate_required(posted, fields)
      errors = {}
      fields.each do |key|
        if (!(posted.include?(key) && !posted[key].nil? && posted[key].length > 0))
          errors[key] = "#{key.capitalize} is required."
        end
      end

      errors
    end

  end

end; end;
