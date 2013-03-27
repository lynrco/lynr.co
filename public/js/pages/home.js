define(function(require) {

  var frame = document.querySelector('.video-frame');
  var ratio = frame.width / frame.height;
  var evt = require('modules/domEvents');
  evt.on(window, 'resize', resizeFrame);
  resizeFrame();

  function resizeFrame() {
    frame.style.height = (frame.offsetWidth / ratio) + 'px';
  }

});
