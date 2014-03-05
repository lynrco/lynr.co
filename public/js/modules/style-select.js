define(function(require) {

  var clazz = require('modules/clazz');
  var evt = require('modules/dom-events');

  var defaults = {
    className: 'sselect',
    copyClasses: true,
    displayClassName: 'sselect-display',
    focusClassName: 'sselect-focus'
  };

  function initSelect(el, opts) {
    if (!el) { return; }
    opts = opts || {};
    var elder = el.parentNode || el.parentElement;
    // Create the elements
    var wrapper = createElement('span', fetch(opts, 'className'));
    var display = createElement('span', fetch(opts, 'displayClassName'));
    var clone = el.cloneNode(true);
    // Build the structure
    wrapper.appendChild(clone);
    wrapper.appendChild(display);
    if (fetch(opts, 'copyClasses')) {
      wrapper.className = clone.className + wrapper.className;
    }
    updateDisplay(clone, display, false);
    // Bind the event
    evt.on(clone, 'change', function(e) { updateDisplay(clone, display, e); });
    evt.on(clone, 'focus', function(e) { clazz.add(wrapper, fetch(opts, 'focusClassName')); });
    evt.on(clone, 'blur', function(e) { clazz.remove(wrapper, fetch(opts, 'focusClassName')); });
    // Put it in the DOM
    elder.replaceChild(wrapper, el);
  }

  function createElement(type, classname) {
    var el = document.createElement(type);
    clazz.add(el, classname);
    return el;
  }

  function fetch(opts, property) {
    return opts[property] || defaults[property];
  }

  function updateDisplay(select, display, e) {
    var idx = select.selectedIndex;
    var option = select.options[idx];
    display.innerHTML = option.innerHTML;
  }

  return initSelect;

});
