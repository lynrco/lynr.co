define(function(require) {

  var api = {
    billing: initBilling
  };

  function initBilling() {
    require(
      ['modules/domEvents', 'modules/clazz', 'modules/stripe'],
      function(evt, clazz, setupStripeForm) {
        var form = document.querySelector('form.m-billing');
        var div = document.querySelector('div.m-billing');
        setupStripeForm(form);
        evt.on(document.querySelector('a.btn-create'), 'click', function(e) {
          evt.prevent(e);
          clazz.toggle(form, 'm-billing-active');
          clazz.toggle(div, 'm-billing-active');
        });
      }
    );
  }

  function showForm(e) {
  }

  return api;

});
