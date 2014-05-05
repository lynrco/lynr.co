define(
  ['modules/dom-events', 'modules/data-attrs', 'modules/fastdomp', 'modules/asset-path'],
  function(evt, data, fastdomp, assetPath) {

    var fastdom = fastdomp.fastdom;

    // Returns Promise
    function createFullImage(image) {
      var el = document.createElement('img');
      var wrap = document.createElement('div');
      evt.on(el, 'load', onFullLoaded.bind(el, image));
      evt.on(el, 'click', exitFullscreen.bind(el));
      return fastdomp.read(function(resolve, reject) {
        var src = data.get(image, 'full-src');
        var imageClass = image.className;
        var imageParent = image.parentElement;
        fastdom.write(function() {
          el.src = assetPath() + '/img/blank-75x25.gif';
          el.alt = image.alt;
          el.className = imageClass + ' vehicle-image-full';
          data.set(el, 'full-src', src);
          wrap.className = 'vehicle-image-wrap';
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
        box.className = 'vehicle-images';
        resolve(box);
      });
    }

    function enterFullscreen(e) {
      var full = this;
      getContainer().then(function(container) {
        fastdom.read(function() {
          var src = data.get(full, 'full-src');
          fastdom.write(function() {
            container.className += ' vehicle-images-active';
            full.className += ' vehicle-image-active';
            full.src = src;
          });
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

    // Returns Promise
    function getContainer() {
      return fastdomp.read(function(resolve, reject) {
        resolve(document.querySelector('.vehicle-images'));
      });
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
