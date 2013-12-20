define(function(require) {

  var mixpanel = require('mixpanel');

  mixpanel.track_pageview();
  mixpanel.track_forms('form.signup', 'Signed up for Launch Notification');

});
