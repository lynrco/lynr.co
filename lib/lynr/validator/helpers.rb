require 'bson'

module Lynr; module Validator;

  # # `Lynr::Validator::Helpers`
  #
  # Validation methods for checking form input against specified rules.
  #
  module Helpers

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

    # ## `Helpers#is_valid_slug?(slug)`
    #
    # Check to see if `slug` should be permitted. Slugs must contain only
    # lowercase letters and hyphens.
    #
    def is_valid_slug?(slug)
      BSON::ObjectId.legal?(slug) || !(%r(^[a-z-]+$) =~ slug).nil?
    end

  end

end; end;
