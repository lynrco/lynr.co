define(function(require) {

  var api = {
    signup: initSignup
  };

  function initSignup() {
    var card = require('modules/credit-card-numbers');
    var cardNumber = document.querySelector('#card_number');
    var evt = require('modules/dom-events');
    var setupStripeForm = require('modules/stripe')
    var styleCheckbox = require('modules/style-checkbox');

    setupStripeForm(document.querySelector('form.signup'));
    styleCheckbox(document.querySelector('#agree_terms'));

    evt.on(cardNumber, 'keyup', function(e) {
      // Only reformat if typed character is a digit or whitespace
      if (!!/[\d ]/.test(String.fromCharCode(e.which))) {
        cardNumber.value = card.format(cardNumber.value);
      }
    });
  }

  return api;

});
