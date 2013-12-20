(function() {

  requirejs.config({
    map: {
      '*': {
        'domReady': 'libs/domReady-2.0.0',
        'jquery': 'libs/jquery-1.10.2.min',
        'jquery.transloadit': 'libs/jquery.transloadit2-v2.1.0',
        'mixpanel': 'modules/mixpanel',
        'spinner': 'libs/spin-1.3.2',
        'stripe': 'https://js.stripe.com/v1/',
        'underscore': 'libs/underscore-1.3.3'
      }
    },
    shim: {
      'libs/jquery-1.10.2.min': {
        exports: 'jQuery'
      },
      'libs/jquery.transloadit2-v2.1.0': {
        deps: ['jquery'],
        exports: 'jQuery.fn.transloadit'
      },
      'libs/spin-1.3.2': {
        exports: 'Spinner'
      },
      'https://js.stripe.com/v1/': {
        exports: 'Stripe'
      }
    }
  });

  require(['domReady'], function(domready) {
    domready(function() {
      require(['pages/' + document.body.id], function(page) {
        // Run page init
        if ('function' === typeof page) { page(); }
        if (page && ('function' === typeof page._init)) { page._init(); }

        // Run subsection functions
        var names = document.body.className.split(' ');
        var i, name;
        for (i = 0; i < names.length; i++) {
          name = names[i];
          if (page && ('function' === typeof page[name])) { page[name](); }
        }
      });
    });
  });

  var menuLinks = document.querySelectorAll('.menu-link');
  if (menuLinks.length > 0) {
    require(['modules/menu'], function(menu) { menu(menuLinks); });
  }

})();
