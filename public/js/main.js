(function() {

  requirejs.config({
    map: {
      '*': {
        'domReady': 'libs/domReady-2.0.0',
        'jquery': 'libs/jquery-1.10.2.min',
        'stripe': 'https://js.stripe.com/v1/',
        'underscore': 'libs/underscore-1.3.3'
      }
    },
    shim: {
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

  require(['modules/menu'], function(menu) {
    menu(document.querySelector('.menu-link'));
  })

})();
