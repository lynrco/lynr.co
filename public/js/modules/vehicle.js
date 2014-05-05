define(
  ['modules/dom-events', 'modules/data-attrs', 'modules/clazz', 'modules/fastdomp', 'modules/asset-path'],
  function(evt, data, clazz, fastdomp, assetPath) {

    var fastdom = fastdomp.fastdom;
    var Promise = fastdomp.promise;

    var containerPromise = false;

    // Returns Promise
    function createFullImage(image) {
      var el = document.createElement('img');
      var wrap = document.createElement('div');
      evt.on(el, 'load', onFullLoaded.bind(el, image));
      evt.on(el, 'click', exitFullscreen.bind(el));
      return fastdomp.read(function(resolve, reject) {
        var src = data.get(image, 'full-src');
        var imageClass = image.className;
        fastdom.write(function() {
          el.src = assetPath() + '/img/blank-75x25.gif';
          el.alt = image.alt;
          el.className = imageClass;
          clazz.add(el, 'vehicle-image-full');
          data.set(el, 'full-src', src);
          clazz.add(wrap, 'vehicle-image-wrap');
          wrap.appendChild(el);
          resolve({ thumb: image, full: wrap });
        });
      });
    }

    // Returns Promise
    function createFullContainer(images) {
      return fastdomp.write(function(resolve, reject) {
        var box = images.reduce(
          function(memo, image) {
            return memo.appendChild(image.full) && memo;
          }, document.createElement('div')
        );
        clazz.add(box, 'vehicle-images');
        resolve(box);
      });
    }

    function enterFullscreen(e) {
      var full = this;
      getContainer().then(function(container) {
        clazz.add(container, 'vehicle-images-active');
        clazz.add(full, 'vehicle-image-active');
        fastdom.read(function() {
          var src = data.get(full, 'full-src');
          fastdom.write(function() { full.src = src; });
        });
      });
    }

    function exitFullscreen(e) {
      var full = this;
      clazz.remove(full, 'vehicle-image-active');
      getContainer().then(function(container) { clazz.remove(container, 'vehicle-images-active'); });
    }

    // Returns Promise
    function getContainer() {
      if (!containerPromise) {
        containerPromise = fastdomp.read(function(resolve, reject) {
          resolve(document.querySelector('.vehicle-images'));
        });
      }
      return containerPromise;
    }

    // Returns Promise
    function getExpandedImages(images) {
      return Promise.all(images.map(createFullImage))
    }

    // Returns Promise
    function getVehicleImages() {
      return fastdomp.read(function(resolve, reject) {
        resolve(Array.prototype.slice.call(document.querySelectorAll('.vehicle-image')));
      });
    }

    // Returns Promise
    function getWrapper() {
      return fastdomp.read(function(resolve, reject) {
        resolve(document.querySelector('.window'));
      });
    }

    function initModals() {
      getVehicleImages().then(getExpandedImages).then(createFullContainer).then(function(imagesDiv) {
        getWrapper().then(function(wrapper) {
          fastdom.write(function() { wrapper.appendChild(imagesDiv); });
        });
      }).catch(function(err) { console.log(err); });
    }

    function initViews() {
      if (typeof window.DeviceOrientationEvent === 'undefined') { return; }
      evt.on(window, 'orientationchange', onOrientationChange);
    }

    function onFullLoaded(thumb, e) {
      var full = this;
      evt.on(thumb, 'click', enterFullscreen.bind(full));
    }

    function onOrientationChange(e) {
      fastdomp.read(function(resolve) {
        var node = document.querySelector('.vehicle-photos-inner');
        resolve({ node: node, display: node.style.display });
      }).then(function(inner) {
        fastdom.write(function() {
          inner.node.style.display = inner.display === 'inline-block' ? 'block' : 'inline-block';
        });
      }).catch(function(err) { console.log(err); });
    }

    return {
      initModals: initModals,
      initViews: initViews
    };

  }
);
