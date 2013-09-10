define(
  ['modules/clazz', 'modules/domEvents', 'modules/data-attrs'],
  function(clazz, evt, data) {

    var body = document.querySelector('html');
    
    function init(args) {
      var els = [];
      var i;

      if (!args) { return; }
      else if (args.length > 0) { els = Array.prototype.slice.call(args); }
      else { els = [args]; }

      for (i = 0; i < els.length; i++) { bindEvents(els[i], els); }
    }

    function bindEvents(el, els) {
      var type = data.get(el, 'type')
      var types = [];
      var i;
      for (i = 0; i < els.length; i++) {
        if (el === els[i]) { continue; }
        types.push(data.get(els[i], 'type'));
      }
      clazz.add(body, 'menu-active');
      evt.on(el, 'click', function(e) {
        evt.prevent(e);
        for (i = 0; i < types.length; i++) { clazz.remove(body, 'menu-visible-' + types[i]); }
        clazz.toggle(body, 'menu-visible-' + type);
      });
    }

    return init;

  }
);
