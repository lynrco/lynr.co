/*!
 * domEvents, a simple interface for interacting with DOM events
 * (c) Bryan J Swift 2012
 * https://github.com/bryanjswift/require-js-bootstrap
 * license MIT
 */
define(function() {

  // Functions taken from http://www.quirksmode.org/blog/archives/2005/10/_and_the_winner_1.html
  function addEvent(obj, type, fn) {
    if (obj && obj.addEventListener) {
      obj.addEventListener(type, fn, false);
    } else if (obj && obj.attachEvent) {
      obj["e" + type + fn] = fn;
      obj[type + fn] = function() { obj["e" + type + fn](window.event); };
      obj.attachEvent("on" + type, obj[type + fn]);
    }
  }

  function removeEvent(obj, type, fn) {
    if (obj && obj.removeEventListener) {
      obj.removeEventListener(type, fn, false);
    } else if (obj && obj.detachEvent) {
      obj.detachEvent("on" + type, obj[type + fn]);
      obj[type + fn] = null;
      obj["e" + type + fn] = null;
    } else if (console && console.warn) {
      console.warn('no way to remove event from', obj, type);
    }
  }

  function preventEvent(e) {
    if (e && e.preventDefault) { e.preventDefault(); }
    if (e) { e.returnValue = false; }
  }

  function stopEvent(e) {
    if (e.stopPropagation) { e.stopPropagation(); }
  }

  return {
    off: removeEvent,
    on: addEvent,
    prevent: preventEvent,
    stop: stopEvent
  };

});
