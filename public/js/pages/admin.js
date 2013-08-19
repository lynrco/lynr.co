define(function(require) {

  var api = {
    account: initAccount,
    billing: initBilling
  };

  var transloaditOpts = {
    autoSubmit: false,
    wait: true,
    onSuccess: uploadSuccess
  };

  function initAccount() {
    require(
      ['jquery', 'jquery.transloadit'],
      function($, jtl) {
        var form = $('#account-photo');
        form.transloadit(transloaditOpts);
        $('#photo').on('change', function(e) { form.trigger('submit.transloadit'); });
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

  function uploadSuccess(assembly) {
    var results = assembly.results;
    var input = $('input[name=image]');
    var original = results[':original'][0];
    var full = results.resize_full[0];
    var thumb = results.resize_thumb[0];
    var image = {
      url: full.url,
      width: full.meta.width,
      height: full.meta.height
    };
    input.val(JSON.stringify(image));
  }

  return api;

});
