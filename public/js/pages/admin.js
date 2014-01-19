define(function(require) {

  var api = {
    _init: init,
    account: initAccount,
    billing: initBilling
  };

  function init() {
    initImageForms(document.querySelectorAll('.f-image'));
  }

  function initAccount() {
    require(
      ['modules/dom-events'],
      function(evt) {
        evt.on(document.querySelector('.f-image-preview'), 'error', function(e) {
          var img = e.target;
          img.src = '/img/blank.gif';
          img.width = '160';
          img.height = '160';
          img.className = 'f-image-preview f-image-preview-empty icon-add-photo';
        });
      }
    );
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

  function initImageForms(forms) {
    if (forms.length > 0) {
      require(['modules/transloadit-form'], function(tlit) { tlit(forms); });
    }
  }

  return api;

});
