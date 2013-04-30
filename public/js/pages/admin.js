define(function(require) {

  var api = {
    billing: initBilling
  };

  function initBilling() {
    require(['modules/stripe'], function(setupStripeForm) {
      setupStripeForm(document.querySelector('form.billing'));
    });
  }

  return api;

});
