define(function(require) {

  var mixpanel = require('mixpanel');
  var evt = require('modules/dom-events');

  function setupHome() {
    var form = document.querySelector('form.signup-demo');
    if (!form) { return; }

    evt.on(form, 'submit', trackFormSubmit);
    if (document.querySelector('#agree_terms')) { styleInputs(); }
  }

  function styleInputs() {
    var styleCheckbox = require('modules/style-checkbox');
    styleCheckbox(document.querySelector('#agree_terms'));
  }

  function trackFormSubmit(e) {
    mixpanel.track('signup.demo', {
      description: 'Signed up for Demo Account',
      url: window.location.pathname,
      domain: window.location.host || window.location.hostname
    });
  }

  return setupHome;

});
