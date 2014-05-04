define(
  ['modules/dom-events', 'modules/data-attrs', 'modules/fastdomp', 'promise'],
  function(evt, data, fastdomp, Promise) {

    var fastdom = fastdomp.fastdom;

    function createFullImage(image) {
      return fastdomp.read(function(resolve, reject) {
        var src = data.get(image, 'full-src');
        var imageClass = image.className;
        var imageParent = image.parentElement;
        fastdom.write(function() {
          var el = document.createElement('img');
          var wrap = document.createElement('div');
          evt.on(el, 'load', onFullLoaded.bind(el, image));
          evt.on(el, 'click', exitFullscreen.bind(el));
          el.src = src;
          el.alt = image.alt;
          el.className = imageClass + ' vehicle-image-full';
          wrap.className = 'vehicle-image-wrap';
          wrap.appendChild(el);
          resolve({ thumb: image, full: wrap });
        });
      });
    }

    function createFullContainer(images) {
      return fastdomp.write(function(resolve, reject) {
        var box = images.reduce(
          function(memo, image) {
            return memo.appendChild(image.full) && memo;
          }, document.createElement('div')
        );
        box.className = 'vehicle-images';
        resolve(box);
      });
    }

    function enterFullscreen(e) {
      var full = this;
      getContainer().then(function(container) {
        fastdom.write(function() {
          container.className += ' vehicle-images-active';
          full.className += ' vehicle-image-active';
        });
      });
    }

    function exitFullscreen(e) {
      var full = this;
      fastdom.read(function() {
        var container = document.querySelector('.vehicle-images');
        var containerClass = container.className;
        var fullClass = full.className;
        fastdom.write(function() {
          container.className = containerClass.replace(/ vehicle-images-active/g, '');
          full.className = fullClass.replace(/ vehicle-image-active/g, '');
        });
      });
    }

    function getContainer() {
      return fastdomp.read(function(resolve, reject) {
        resolve(document.querySelector('.vehicle-images'));
      });
    }

    function getExpandedImages(images) {
      return Promise.all(images.map(createFullImage))
    }

    function getVehicleImages() {
      return fastdomp.read(function(resolve, reject) {
        resolve(Array.prototype.slice.call(document.querySelectorAll('.vehicle-image')));
      });
    }

    function getWrapper() {
      return fastdomp.read(function(resolve, reject) {
        resolve(document.querySelector('.window'));
      });
    }

    function init() {
      getVehicleImages().then(getExpandedImages).then(createFullContainer).then(function(imagesDiv) {
        getWrapper().then(function(wrapper) {
          fastdom.write(function() { wrapper.appendChild(imagesDiv); });
        });
      }).catch(function(err) { console.log(err); });
    }

    function onFullLoaded(thumb, e) {
      var full = this;
      evt.on(thumb, 'click', enterFullscreen.bind(full));
    }

    //return init;
    return function() {};

  }
);
