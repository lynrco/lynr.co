define(function(require) {

  var api = {
    _init: initAgree,
    signup: initSignup
  };

  function initAgree() {
    var styleCheckbox = require('modules/style-checkbox');
    styleCheckbox(document.querySelector('#agree_terms'));
  }

  function initSignup() {
    var setupStripeForm = require('modules/stripe')

    setupStripeForm(document.querySelector('form.signup'));
  }

  return api;

});
