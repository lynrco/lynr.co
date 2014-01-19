define(function(require) {

  var api = {
    _init: initAdmin,
    billing: initBilling
  };

  function initAdmin() {
    initImageForms(document.querySelectorAll('.f-image'));
  }

  function initImageForms(forms) {
    if (forms.length > 0) {
      require(['modules/transloadit-form'], function(tlit) { tlit(forms); });
    }
  }

  function initBilling() {
    require(
      ['modules/domEvents', 'modules/clazz', 'modules/stripe'],
      function(evt, clazz, setupStripeForm) {
        var form = document.querySelector('form.m-billing');
        var div = document.querySelector('div.m-billing');
        setupStripeForm(form);
        evt.on(document.querySelector('a.btn-positive'), 'click', toggleActive);
        evt.on(document.querySelector('a.btn-negative'), 'click', toggleActive);

        function toggleActive(e) {
          evt.prevent(e);
          clazz.toggle(form, 'm-billing-active');
          clazz.toggle(div, 'm-billing-active');
        }
      }
    );
  }

  return api;

});
