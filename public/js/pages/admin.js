define(function(require) {

  var api = {
    account: initAccount,
    billing: initBilling,
    'vehicle-photos': initVehiclePhotos
  };

  var baseTransloaditOpts = {
    autoSubmit: false,
    triggerUploadOnFileSelection: true,
    wait: true
  };

  function initAccount() {
    require(
      ['jquery', 'jquery.transloadit'],
      function($, jtl) {
        $('#account-photo').transloadit(transloaditOpts('account'));
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
        evt.on(document.querySelector('a.btn-create'), 'click', function(e) {
          evt.prevent(e);
          clazz.toggle(form, 'm-billing-active');
          clazz.toggle(div, 'm-billing-active');
        });
      }
    );
  }

  function initVehiclePhotos() {
    require(
      ['jquery', 'jquery.transloadit'],
      function($, jtl) {
        var forms = $('.vehicle-photo');
        forms.transloadit(transloaditOpts('vehicle-photos'));
      }
    );
  }

  function transloaditOpts(page) {
    var specific;
    switch (page) {
      case 'account':
        specific = {
          onSuccess: uploadAccountSuccess,
          fields: 'input[name=dealership_id]'
        };
        break;
      default:
        specific = {};
        break;
    }
    return $.extend(specific, baseTransloaditOpts);
  }

  function uploadAccountSuccess(assembly) {
    var results = assembly.results;
    var input = $('input[name=image]');
    var original = results[':original'][0];
    var full = results.resize_full[0];
    var thumb = results.resize_thumb[0];
    var image = {
      url: full.url,
      src: full.url,
      width: full.meta.width,
      height: full.meta.height
    };
    input.val(JSON.stringify(image));
    $('img.photo-preview').attr(image);
  }

  function uploadPhotosSuccess(assembly) {
  }

  return api;

});
