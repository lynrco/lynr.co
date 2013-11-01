require 'libxml'

module Lynr; module Converter;

  class LibXmlHelper

    def self.contents(context, xpath)
      enum = context.find(xpath) if context
      (enum || []).map { |node| node.content }
    end

    def self.values(context, xpath)
      enum = context.find(xpath) if context
      (enum || []).map { |node| node.value }
    end

  end

end; end;
