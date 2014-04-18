require 'rspec/expectations'

RSpec::Matchers.define :have_element do |css_selector|
  match do |actual|
    actual.css(css_selector).first != nil
  end
  failure_message_for_should do |actual|
    "expected #{actual.class.name.to_s} to have element matching #{css_selector}"
  end
  failure_message_for_should_not do |actual|
    "did not expect #{actual.class.name.to_s} to have element matching #{css_selector}"
  end
  description do |actual|
    "have element for #{css_selector}"
  end
end
