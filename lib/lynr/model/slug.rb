module Lynr; module Model;

  # # `Lynr::Model::Slug`
  #
  # Encapsulates the logic necessary to turn an arbitrary string into a URI
  # safe String, where URI safe means alphanumeric and hyphens.
  #
  class Slug < String

    # ## `Slug.new(name, default)`
    #
    # Creates a new String subclass by calling `Slug.slugify` on `name`
    # provided it is not nil or emtpty. If `name` is nil or empty use
    # `default` instead.
    #
    def initialize(name, default)
      if name.nil? or name.empty?
        super(default.to_s)
      else
        super(Slug.slugify(name))
      end
    end

    # ## `Slug.slugify(str)`
    #
    # Perform the act of turning an existing String into a URI safe string.
    #
    def self.slugify(str)
      str.strip.downcase.gsub(/[']+/, '').gsub(/\W+/, '-')
    end

  end

end; end;
