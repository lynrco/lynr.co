define(function(require) {

  require('stripe').setPublishableKey('pk_HXlEvJ3XN3plgPOBzzpulQ3JzaLGf');

  function emptyElement(el) {
    while (el.childNodes.length !== 0) {
      el.removeChild(el.childNodes[0]);
    }
  }

  function setupStripeForm(form) {
    var messages = document.getElementById('messages');
    var button = form.querySelector('button[type=submit]');
    var evt = require('modules/domEvents');
    evt.on(form, 'submit', handleFormSubmit);

    function handleFormSubmit(e) {
      evt.prevent(e);
      emptyElement(messages);
      button.setAttribute('disabled', true);
      require('stripe').createToken(form, handleStripeResponse);
      return false;
    }

    function handleStripeResponse(code, res) {
      console.log(code, res);
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
      button.removeAttribute('disabled');
    }

    function handleStripeResponseSuccess(res) {
      document.getElementById('stripeToken').value = res.id;
      form.submit();
    }

  }

  return setupStripeForm;
  
});
