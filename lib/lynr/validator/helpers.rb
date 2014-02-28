require 'bson'

module Lynr; module Validator;

  # # `Lynr::Validator::Helpers`
  #
  # Validation methods for checking form input against specified rules.
  #
  module Helpers

    # ## `Helpers#error_for_slug(dao, slug)`
    #
    # Check the validity with `#is_valid_slug?` and existence of a slug with
    # `dao` and return the appropriate error message if slug is not valid or
    # exists in the database.
    #
    def error_for_slug(dao, slug)
      if !is_valid_slug?(slug)
        "Dealership handle may contain only lowercase letters, numbers and hyphens."
      elsif (dao.slug_exists?(slug))
        "Dealership handle, <em>#{slug}</em>, is in use by someone else."
      else
        nil
      end
    end

    # ## `Helpers#is_valid_slug?(slug)`
    #
    # Check to see if `slug` should be permitted. Slugs must contain only
    # lowercase letters and hyphens.
    #
    def is_valid_slug?(slug)
      BSON::ObjectId.legal?(slug) || !(%r(^[a-z0-9-]+$) =~ slug).nil?
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
