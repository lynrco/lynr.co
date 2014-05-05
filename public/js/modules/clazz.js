/*!
 * clazz, a simple interface for interacting with class attributes
 * (c) Bryan J Swift 2012
 * https://github.com/bryanjswift/require-js-bootstrap
 * license MIT
 */
define(['modules/fastdomp'], function(fastdomp) {
  var hasTrim = !!String.prototype.trim;
  var fastdom = fastdomp.fastdom;
  var Promise = fastdomp.promise;
  var api;

  if (typeof document.body.classList === 'undefined') {
    api = {
      add: addClass,
      has: hasClass,
      remove: removeClass,
      toggle: toggleClass
    };
  } else {
    api = {
      add: addClassCL,
      has: hasClassCL,
      remove: removeClassCL,
      toggle: toggleClassCL
    };
  }

  /* Methods that use classList property */
  function addClassCL(node, className) {
    return node.classList.add(className);
  }

  function hasClassCL(node, className) {
    return new Promise(function(resolve, reject) { resolve(node.classList.contains(className)); });
  }

  function removeClassCL(node, className) {
    return node.classList.remove(className);
  }

  function toggleClassCL(node, className) {
    return node.classList.toggle(className);
  }

  /* Methods that manipulate className directly */
  function addClass(node, className) {
    api.has(node, className).then(function(has) {
      if (!has) { return; }
      fastdom.read(function() {
        var origClassName = node.className;
        fastdom.write(function() { node.className = origClassName + ' ' + className; });
      });
    });
  }

  function hasClass(node, className) {
    return fastdomp.read(function(resolve, reject) { resolve(api.has(node, className)); });
  }

  function removeClass(node, className) {
    fastdom.read(function() {
      var origClassName = node.className;
      fastdom.write(function() {
        if (hasTrim) {
          node.className = origClassName.replace(className, '').trim();
        } else {
          node.className = origClassName.replace(className, '');
        }
      });
    });
  }

  function toggleClass(node, className) {
    return api.has(node, className).then(function(has) {
      if (has) {
        removeClass(node, className);
      } else {
        addClass(node, className);
      }
      return node;
    });
  }

  return api;
});
