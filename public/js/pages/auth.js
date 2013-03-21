define(function(require) {

  var api = {
    signup: initSignup
  };

  /* Signup */
  function initSignup() {
    require('stripe').setPublishableKey('pk_HXlEvJ3XN3plgPOBzzpulQ3JzaLGf');
    require('modules/domEvents').on(document.querySelector('form.signup'), 'submit', handleSignupSubmit);
  }

  function handleSignupSubmit(e) {
    var evt = require('modules/domEvents');
    evt.stop(e);
    var form = document.querySelector('form.signup');
    form.querySelector('button[type=submit]').setAttribute('disabled', true);
    require('stripe').createToken(form, handleStripeResponse);
    return false;
  }

  function handleStripeResponse(code, res) {
    console.log(code, res);
    if (response.error) {
      handleStripResponseError(res);
    } else {
      handleStripResponseSuccess(res);
    }
  }

  function handleStripeResponseError(res) {
    var form = document.querySelector('form.signup');
    var messages = document.getElementById('messages');
    var error = document.createElement('p');
    error.className = 'error';
    error.innerHTML = response.error.message;
    form.querySelector('button[type=submit]').setAttribute('disabled', false);
  }

  function handleStripeResponseSuccess(res) {
    var form = document.querySelector('form.signup');
    document.getElementById('stripeToken').value = res.id;
    form.submit();
  }

  return api;

});
