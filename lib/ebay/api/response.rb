require 'libxml'

require './lib/ebay'

module Ebay

  # # `Ebay::Api::Response`
  #
  # Generic holder for the type of data returned from the eBay API. It is intended
  # to make accessing the contents of XML elements simpler while remaining performant.
  #
  class Api::Response

    EMPTY_RESPONSE = <<-EOF
<?xml version="1.0" encoding="UTF-8"?><EmptyResponse xmlns="#{Ebay::NS}" />
    EOF

    # ## `Response.new(xml)`
    #
    # Create a new response object for the provided `String` of XML. If `xml` is
    # `nil` then default to `Ebay::Api::Response::EMPTY_RESPONSE`.
    #
    def initialize(xml)
      if xml.nil?
        @xml = EMPTY_RESPONSE
      else
        @xml = xml
      end
    end

    # ## `Response#valid?`
    #
    # Codify the eBay API's way of specifying a response came from a successful
    # request, namely the `<Ack>` element contains the `String` value 'Success'.
    #
    def success?
      fetch('Ack', default='Failure') == 'Success'
    end

    # ## `Response#fetch(name, default)`
    #
    # Retrieve the contents of the first XML element with `name` and return them.
    # If no elements have a node name of `name` then return `default`, which is `nil`
    # when not provided. `default` is also returned if there is a parsing error.
    #
    def fetch(name, default=nil)
      reader = LibXML::XML::Reader.string(@xml)
      value = default
      while reader.read
        next unless reader.node_type == LibXML::XML::Reader::TYPE_ELEMENT
        if reader.node.name == name
          value = reader.read_inner_xml
          break
        end
      end
      value
    rescue LibXML::XML::Error
      # If rescue is return value then use default
      default
    ensure
      reader.close
    end

  end

end
