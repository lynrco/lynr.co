require 'resolv'

module Lynr; module Validator;

  module Helpers

    def is_valid_email?(email)
      valid = true
      at_index = email.index('@')
      mx_records = []
      a_records = []
      if (at_index <= 0)
        valid = false
      else
        parts = email.partition('@')
        local = parts[0]
        domain = parts[2]
        if ((local.length < 1 || local.length > 64) || # local part length exceeded
            (domain.length < 1 || domain.length > 255) || # domain part length exceeded
            (local.start_with?(".") || local.end_with?(".")) || # local part starts or ends with '.'
            (!local.index(%r(\.\.)).nil?) || # local part has two consecutive dots
            (domain.index(%r(^[A-Za-z0-9\-\.]+$)) != 0) || # invalid character in domain part
            (!domain.index(%r(\.\.)).nil?)) then # domain part has two consecutive dots
          valid = false
        end
      end

      if (valid)
        Resolv::DNS.open do |dns|
          mx_records = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
          a_records = dns.getresources(domain, Resolv::DNS::Resource::IN::A)
        end
        valid = mx_records.size > 0 || a_records.size > 0
      end

      valid
    end

    def is_valid_password?(password)
      password.length > 3
    end

  end

end; end;
