define(function(require) {

  var api = {
    signup: initSignup
  };

  function initSignup() {
    var setupStripeForm = require('modules/stripe')
    var styleCheckbox = require('modules/style-checkbox');
    setupStripeForm(document.querySelector('form.signup'));
    styleCheckbox(document.querySelector('#agree_terms'));
  }

  return api;

});
