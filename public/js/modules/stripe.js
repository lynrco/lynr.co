define(function(require) {

  var stripe = require('stripe');

  function emptyElement(el) {
    while (el.childNodes.length !== 0) {
      el.removeChild(el.childNodes[0]);
    }
  }

  function setupStripeForm(form) {
    if (!document.getElementById('stripeToken')) { return; }

    var card = require('modules/credit-card-numbers');
    var evt = require('modules/dom-events');
    var clazz = require('modules/clazz');
    var data = require('modules/data-attrs');

    var button = form.querySelector('button[type=submit]');
    var cardNumber = document.querySelector('#card_number');
    var messages = document.getElementById('messages');

    stripe.setPublishableKey(data.get(form, 'stripe-pub'));

    if (!document.getElementById('stripeToken').value) {
      evt.on(form, 'submit', handleFormSubmit);
    }
    // TODO: if there is a `stripeToken` on change of card inputs add the
    // form submit handler

    evt.on(cardNumber, 'keyup', function(e) {
      // Only reformat if typed character is a digit or whitespace
      if (!!/[\d ]/.test(String.fromCharCode(e.which))) {
        cardNumber.value = card.format(cardNumber.value);
      }
    });

    function handleFormSubmit(e) {
      evt.prevent(e);
      emptyElement(messages);
      clazz.add(messages, 'empty');
      button.setAttribute('disabled', true);
      stripe.createToken(form, handleStripeResponse);
      return false;
    }

    function handleStripeResponse(code, res) {
      if (res.error) {
        handleStripeResponseError(res);
      } else {
        handleStripeResponseSuccess(res);
      }
    }

    function handleStripeResponseError(res) {
      var error = document.createElement('p');
      error.className = 'msg msg-error';
      error.innerHTML = res.error.message;
      messages.appendChild(error);
      clazz.remove(messages, 'empty');
      button.removeAttribute('disabled');
    }

    function handleStripeResponseSuccess(res) {
      document.getElementById('stripeToken').value = res.id;
      form.submit();
    }

  }

  return setupStripeForm;

});
