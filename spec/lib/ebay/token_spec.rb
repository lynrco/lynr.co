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
  <Timestamp>2014-01-08T23:36:46.104Z</Timestamp>
  <Ack>Success</Ack>
  <Version>853</Version>
  <Build>E853_CORE_API_16609591_R1</Build>
  <eBayAuthToken>AgAAAA**AQAAAA**aAAAAA**A+HNUg**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhC5eAowidj6x9nY+seQ*\
*+3cCAA**AAMAAA**+iEIGKazUGyDne0jAHjhpYmnv/Ul7M6BYufxbOzIlrY9mjzAQV2bM5XUyEjHLZkrb6TZx1zZ2Tb9U8k5pOqTzgJ\
B16pA1YyzJ31sGD+2+GRQ0r9XG6ve+jK0TSk1OnH6wmdxfsP4XzRZka1akouci0Gx2TI7sgXTGdOP9yJQ/gGFCEIdaCA+gtV8hMcniBW\
ZtmfLi0rJH/yQUkZ8ix5IUFoo9+lKGtysGUh3vxla9jvnFSrzAA3q8ii4AcxpTossNlNrRwdlA2FMRro55o8U8x4hyCQdi/Ket5keJtd\
ttf08aVudgVR/l0C76bDtrdVDFEtsfeerj1Nz1+HYeUSCArGU9g1eC9fIgzbEPd9kLOcWIlltbsQWv8BE9h7FhVdHqZhkli343W0gI2E\
GGKO+UOdpb868ebKL+vTZ+L3HxS3iMOn6V3Mtm1ukBFCIEgNxmOfss16WDKtEpfZjpOZ++2N47hy2U+kPssi3KwQHo5iT9mJFkagV9OY\
nK5C5xpZ+sErt8GTd5e0VM7zvpS8TzT2He3Rh5fDQLzmjT345Ofk5MYePf7ld4z5pRc/n+R7z9cFKF7P9jCdq9XRAdjXKW0KsyuV6WvM\
DoEXS4UPv8YT0gmwxwumxb6U0RZ62jnpDJ7cbx0yKu2H7KybP9O4AfS0V5B6gQ1zSFFfysmXtYot/e/sfzt6OqDreSDiScykc5STca8/\
bUX29vmK98uxwrK1eqMS2fgSsV9tC8GUaPZv3WPkJkDWUyOYUWd2EO1CN</eBayAuthToken>
  <HardExpirationTime>2015-07-02T23:36:35.000Z</HardExpirationTime>
</FetchTokenResponse>
    EOF
  }
  let(:silly_success) {
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
    <LongMessage>Header &quot;X-EBAY-API-COMPATIBILITY-LEVEL&quot; with value &quot;(null)&quot; is out \
of range.</LongMessage>
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
      expect(token.id).to eq("AgAAAA**AQAAAA**aAAAAA**A+HNUg**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhC5eAow\
idj6x9nY+seQ**+3cCAA**AAMAAA**+iEIGKazUGyDne0jAHjhpYmnv/Ul7M6BYufxbOzIlrY9mjzAQV2bM5XUyEjHLZkrb6TZx1zZ2T\
b9U8k5pOqTzgJB16pA1YyzJ31sGD+2+GRQ0r9XG6ve+jK0TSk1OnH6wmdxfsP4XzRZka1akouci0Gx2TI7sgXTGdOP9yJQ/gGFCEIdaC\
A+gtV8hMcniBWZtmfLi0rJH/yQUkZ8ix5IUFoo9+lKGtysGUh3vxla9jvnFSrzAA3q8ii4AcxpTossNlNrRwdlA2FMRro55o8U8x4hyC\
Qdi/Ket5keJtdttf08aVudgVR/l0C76bDtrdVDFEtsfeerj1Nz1+HYeUSCArGU9g1eC9fIgzbEPd9kLOcWIlltbsQWv8BE9h7FhVdHqZ\
hkli343W0gI2EGGKO+UOdpb868ebKL+vTZ+L3HxS3iMOn6V3Mtm1ukBFCIEgNxmOfss16WDKtEpfZjpOZ++2N47hy2U+kPssi3KwQHo5\
iT9mJFkagV9OYnK5C5xpZ+sErt8GTd5e0VM7zvpS8TzT2He3Rh5fDQLzmjT345Ofk5MYePf7ld4z5pRc/n+R7z9cFKF7P9jCdq9XRAdj\
XKW0KsyuV6WvMDoEXS4UPv8YT0gmwxwumxb6U0RZ62jnpDJ7cbx0yKu2H7KybP9O4AfS0V5B6gQ1zSFFfysmXtYot/e/sfzt6OqDreSD\
iScykc5STca8/bUX29vmK98uxwrK1eqMS2fgSsV9tC8GUaPZv3WPkJkDWUyOYUWd2EO1CN")
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

    it "is a Time" do
      @response = valid_success
      expect(token.expires).to be_a(Time)
    end

    it "is 2012-05-03T20:36:32.000Z for success" do
      @response = valid_success
      expect(token.expires).to eq(Time.parse('2015-07-02T23:36:35.000Z'))
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
