define(
  ['fastdom', 'promise'],
  function(fastdom, Promise) {

    function read(fn) {
      return new Promise(function(resolve, reject) {
        fastdom.read(fn.bind(this, resolve, reject));
      });
    }

    function write(fn) {
      return new Promise(function(resolve, reject) {
        fastdom.write(fn.bind(this, resolve, reject));
      });
    }

    return {
      fastdom: fastdom,
      promise: Promise,
      read: read,
      write: write
    };

  }
);
