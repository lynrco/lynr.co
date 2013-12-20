define(function(require) {

  require('stripe').setPublishableKey('pk_test_9YtMBBab3Eb9UbPvT0tQ4PAo');

  function emptyElement(el) {
    while (el.childNodes.length !== 0) {
      el.removeChild(el.childNodes[0]);
    }
  }

  function setupStripeForm(form) {
    var messages = document.getElementById('messages');
    var button = form.querySelector('button[type=submit]');
    var evt = require('modules/domEvents');
    var clazz = require('modules/clazz');

    if (!document.getElementById('stripeToken').value) {
      evt.on(form, 'submit', handleFormSubmit);
    }
    // TODO: if there is a `stripeToken` on change of card inputs add the
    // form submit handler

    function handleFormSubmit(e) {
      evt.prevent(e);
      emptyElement(messages);
      clazz.add(messages, 'empty');
      button.setAttribute('disabled', true);
      require('stripe').createToken(form, handleStripeResponse);
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
