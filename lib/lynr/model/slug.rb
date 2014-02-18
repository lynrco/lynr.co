require 'bson'

module Lynr; module Model;

  class Slug < String

    def initialize(name, default)
      if name.nil? or name.empty?
        super(default.to_s)
      else
        super(Slug.slugify(name))
      end
    end

    def self.slugify(str)
      str.strip.downcase.gsub /\W+/, '-'
    end

  end

end; end;
