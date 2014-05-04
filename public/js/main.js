(function() {

  requirejs.config({
    map: {
      '*': {
        'domReady': 'libs/domReady-2.0.0',
        'fastdom': 'libs/fastdom-0.8.4',
        'jquery': 'libs/jquery-2.1.1',
        'jquery.transloadit': 'libs/jquery.transloadit2-v2.4.0',
        'mixpanel': 'modules/mixpanel',
        'modernizr': 'libs/modernizr.custom.79400',
        'promise': 'libs/lie-2.7.0',
        'spinner': 'libs/spin-1.3.2',
        'stripe': 'libs/stripe-20140426',
        'underscore': 'libs/underscore-1.3.3'
      }
    },
    shim: {
      'libs/jquery-2.1.1': {
        exports: 'jQuery'
      },
      'libs/jquery.transloadit2-v2.4.0': {
        deps: ['jquery'],
        exports: 'jQuery.fn.transloadit'
      },
      'libs/modernizr.custom.79400': {
        exports: 'Modernizr'
      },
      'libs/spin-1.3.2': {
        exports: 'Spinner'
      },
      'libs/stripe-20140426': {
        exports: 'Stripe'
      }
    }
  });

  require(['modernizr'], function(modernizr) { /* nothing to see here */ });
  require(['modules/grunticon', 'modules/data-attrs'], function(grunticon, data) {
    var assetPath = data.get(document.body, 'asset-path');
    grunticon([
      assetPath + "/css/icons.data.svg.css",
      assetPath + "/css/icons.data.png.css",
      assetPath + "/css/icons.fallback.css"
    ]);
  });
  require(['domReady'], function(domready) {
    domready(function() {
      if (!(document.body.id || document.body.id.length)) { return; }
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

  require(['mixpanel'], function(mp) {
    mp.track('pageview', {
      title: document.title,
      url: window.location.pathname,
      domain: window.location.host || window.location.hostname
    });
  });

})();
