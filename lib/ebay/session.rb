require 'libxml'

require './lib/ebay'
require './lib/lynr/converter/libxml_helper'

module Ebay

  class Session

    EMPTY_RESPONSE = <<-EOF
<?xml version="1.0" encoding="UTF-8"?><GetSessionIDResponse xmlns="#{Ebay::NS}" />
    EOF

    include Lynr::Converter::LibXmlHelper

    attr_reader :id, :valid
    alias :valid? :valid

    def initialize(response)
      response = EMPTY_RESPONSE if response.nil?
      reader = LibXML::XML::Reader.string(response)
      @id = nil
      @valid = false
      while reader.read
        next if reader.node_type != LibXML::XML::Reader::TYPE_ELEMENT
        n = reader.node
        case n.name
          when 'Ack'
            @valid = n.content == 'Success'
          when 'SessionID'
            @id = n.content
        end
      end
    rescue LibXML::XML::Error
      # Do nothing, defaults are already set
    ensure
      reader.close
    end

  end

end
