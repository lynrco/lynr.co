require 'libxml'
require 'time'

require './lib/ebay'

module Ebay

  # # `Ebay::Token`
  #
  # Represent the data retrieved from the eBay API for authenticating a `Session`.
  #
  class Token

    EMPTY_RESPONSE = <<-EOF
<?xml version="1.0" encoding="UTF-8"?><FetchTokenResponse xmlns="#{Ebay::NS}" />
    EOF

    attr_reader :id, :expires, :valid
    alias :valid? :valid

    # ## `Token.new(response)`
    #
    # Extract the token data from xml `response`. If `response` is malformed or
    # didn't come back with `Ack` element with content of Success then `#id` and `#expires`
    # will be `nil` and `Token#valid?` will be false.
    #
    def initialize(response)
      response = EMPTY_RESPONSE if response.nil?
      reader = LibXML::XML::Reader.string(response)
      @id = nil
      @expires = nil
      @valid = false
      while reader.read
        next unless reader.node_type == LibXML::XML::Reader::TYPE_ELEMENT
        content = reader.read_inner_xml
        case reader.node.name
          when 'Ack'
            @valid = content == 'Success'
          when 'eBayAuthToken'
            @id = content
          when 'HardExpirationTime'
            @expires = Time.parse(content)
        end
      end
    rescue LibXML::XML::Error
      # Do nothing, defaults are already set
    ensure
      reader.close
    end

  end

end
