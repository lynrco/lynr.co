define(
  ['modules/clazz', 'modules/domEvents'],
  function(clazz, evt) {

    var body = document.querySelector('html');
    
    function init(el) {
      evt.on(el, 'click', function(e) {
        evt.prevent(e);
        clazz.toggle(body, 'menu-visible');
      });
    }

    return init;

  }
);
