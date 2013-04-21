define(function(require) {

  var api = {
    billing: initBilling
  };

  function initBilling() {
    var setupStripeForm = require('modules/stripe')
    setupStripeForm(document.querySelector('form.billing'));
  }

  return api;

});
