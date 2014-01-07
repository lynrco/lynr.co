require 'rspec/autorun'
require './spec/spec_helper'

require './lib/ebay/session'

describe Ebay::Session do

  let(:session) { Ebay::Session.new(@response) }
  let(:valid_success) {
    <<-EOF
<GetSessionIDResponse xmlns="urn:ebay:apis:eBLBaseComponents">
  <Timestamp>2014-01-06T22:34:17.745Z</Timestamp>
  <Ack>Success</Ack>
  <Version>851</Version>
  <Build>E851_CORE_API_16556829_R1</Build>
  <SessionID>+3cCAA**69b135111430a471d220cf50ffffff72</SessionID>
</GetSessionIDResponse>
    EOF
  }
  let(:valid_failure) {
    <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<GetSessionIDResponse xmlns="urn:ebay:apis:eBLBaseComponents">
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
</GetSessionIDResponse>
    EOF
  }

  describe "#initialize" do

    it "handles nil gracefully" do
      @response = nil
      expect(session).to be
    end

    it "handles malformed xml gracefully" do
      @response = '<?xml version="1.0" encoding="UTF-8"?><G'
      expect(session).to be
    end

    it "handles well formed success response appropriately" do
      @response = valid_success
      expect(session).to be
    end

    it "handles well formed failure response appropriately" do
      @response = valid_failure
      expect(session).to be
    end

  end

  describe "#valid?" do

    it "is true for success" do
      @response = valid_success
      expect(session.valid?).to be_true
    end

    it "is false for failure" do
      @response = valid_failure
      expect(session.valid?).to be_false
    end

    it "is false for nil"

    it "is false for malformed response"

  end

end
