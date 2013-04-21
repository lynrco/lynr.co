define(function(require) {

  var api = {
    signup: initSignup
  };

  function initSignup() {
    var setupStripeForm = require('modules/stripe')
    setupStripeForm(document.querySelector('form.signup'));
  }

  return api;

});
