define(function(require) {

  var api = {
    _init: init,
    account: initAccount,
    billing: initBilling,
    'vehicle-add': initVehicleForm,
    'vehicle-edit': initVehicleForm,
    'vehicle-view': initVehicleView
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
      ['modules/dom-events', 'modules/clazz', 'modules/stripe'],
      function(evt, clazz, setupStripeForm) {
        var form = document.querySelector('form.m-billing');
        var div = document.querySelector('div.m-billing');
        var toggleActive = toggleActiveBilling.bind(this, evt, clazz, form, div);
        setupStripeForm(form);
        evt.on(document.querySelector('a.btn-positive.m-billing-toggle'), 'click', toggleActive);
        evt.on(document.querySelector('a.btn-negative.m-billing-toggle'), 'click', toggleActive);
      }
    );
  }

  function initImageForms(forms) {
    if (forms.length > 0) {
      require(['modules/transloadit-form'], function(tlit) { tlit(forms); });
    }
  }

  function initVehicleForm() {
    require(
      ['modules/style-select'],
      function(styleSelect) {
        var selects = document.querySelectorAll('.fs select');
        var i = selects.length;
        if (i < 1) { return; }
        do { styleSelect(selects[--i]); } while (i)
      }
    );
  }

  function initVehicleEdit() {
    initVehicleForm();
    require(['modules/vehicle'], function(vehicle) { vehicle.initViews(); });
  }

  function initVehicleView() {
    require(['modules/vehicle'], function(vehicle) {
      vehicle.initModals();
      vehicle.initViews();
    });
  }

  function toggleActiveBilling(evt, clazz, form, div, e) {
    evt.prevent(e);
    clazz.toggle(form, 'm-billing-active');
    clazz.toggle(div, 'm-billing-active');
  }

  return api;

});
