require 'rspec/expectations'

# Checks to see if `actual` contains an element matching the provided
# `css_selector`. Passes if an element is found matching the selector
# so the `css_selector` used must be specific.
#
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
