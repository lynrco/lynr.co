require 'rspec/autorun'
require './spec/spec_helper'

require './lib/ebay/token'

describe Ebay::Token do

  LibXML::XML::Error.reset_handler

  let(:token) { Ebay::Token.new(@response) }
  let(:valid_success) {
    <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<FetchTokenResponse xmlns="urn:ebay:apis:eBLBaseComponents">
  <Timestamp>2010-11-10T20:42:58.943Z</Timestamp>
  <Ack>Success</Ack>
  <Version>693</Version>
  <Build>E693_CORE_BUNDLED_12301500_R1</Build>
  <eBayAuthToken>YourAuthToken</eBayAuthToken>
  <HardExpirationTime>2012-05-03T20:36:32.000Z</HardExpirationTime>
</FetchTokenResponse>
    EOF
  }
  let(:valid_failure) {
    <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<FetchTokenResponse xmlns="urn:ebay:apis:eBLBaseComponents">
  <Timestamp>2014-01-06T21:47:32.194Z</Timestamp>
  <Ack>Failure</Ack>
  <Errors>
    <ShortMessage>Invalid value for header &quot;X-EBAY-API-COMPATIBILITY-LEVEL&quot;.</ShortMessage>
    <LongMessage>Header &quot;X-EBAY-API-COMPATIBILITY-LEVEL&quot; with value &quot;(null)&quot; is out of range.</LongMessage>
    <ErrorCode>10012</ErrorCode>
    <SeverityCode>Error</SeverityCode>
    <ErrorParameters ParamID="0">
      <Value>X-EBAY-API-COMPATIBILITY-LEVEL</Value>
    </ErrorParameters>
    <ErrorParameters ParamID="1">
      <Value>(null)</Value>
    </ErrorParameters>
    <ErrorClassification>RequestError</ErrorClassification>
  </Errors>
  <Version>851</Version>
  <Build>E851_CORE_API_16556829_R1</Build>
</FetchTokenResponse>
    EOF
  }

  describe "#initialize" do

    it "handles nil gracefully" do
      @response = nil
      expect(token).to be
    end

    it "handles malformed xml gracefully" do
      @response = '<?xml version="1.0" encoding="UTF-8"?><G'
      expect(token).to be
    end

    it "handles well formed success response appropriately" do
      @response = valid_success
      expect(token).to be
    end

    it "handles well formed failure response appropriately" do
      @response = valid_failure
      expect(token).to be
    end

  end

  describe "#valid?" do

    it "is true for success" do
      @response = valid_success
      expect(token.valid?).to be_true
    end

    it "is false for failure" do
      @response = valid_failure
      expect(token.valid?).to be_false
    end

    it "is false for nil" do
      @response = nil
      expect(token.valid?).to be_false
    end

    it "is false for malformed response" do
      @response = '<?xml version="1.0" encoding="UTF-8"?><G'
      expect(token.valid?).to be_false
    end

  end

  describe "#id" do

    it "is YourAuthToken for success" do
      @response = valid_success
      expect(token.id).to eq('YourAuthToken')
    end

    it "is nil for failure" do
      @response = valid_failure
      expect(token.id).to be_nil
    end

    it "is nil for nil" do
      @response = nil
      expect(token.id).to be_nil
    end

    it "is nil for malformed response" do
      @response = '<?xml version="1.0" encoding="UTF-8"?><G'
      expect(token.id).to be_nil
    end

  end

  describe "#expires" do

    it "is 2012-05-03T20:36:32.000Z for success" do
      @response = valid_success
      expect(token.expires).to eq('2012-05-03T20:36:32.000Z')
    end

    it "is nil for failure" do
      @response = valid_failure
      expect(token.expires).to be_nil
    end

    it "is nil for nil" do
      @response = nil
      expect(token.expires).to be_nil
    end

    it "is nil for malformed response" do
      @response = '<?xml version="1.0" encoding="UTF-8"?><G'
      expect(token.expires).to be_nil
    end

  end

end
