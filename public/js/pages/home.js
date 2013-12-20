define(function(require) {

  var mixpanel = require('mixpanel');
  var evt = require('modules/domEvents');

  function trackFormSubmit(e) {
    mixpanel.track('signup.launch', {
      description: 'Signed up for Launch Notification',
      url: window.location.pathname,
      domain: window.location.host || window.location.hostname
    });
  }

  function setupHome() {
    var form = document.querySelector('form.signup');
    evt.on(form, 'submit', trackFormSubmit);

    mixpanel.track('pageview', {
      title: document.title,
      url: window.location.pathname,
      domain: window.location.host || window.location.hostname
    });
  }

  return setupHome;

});
