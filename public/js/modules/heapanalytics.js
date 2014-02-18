define(function(require) {
  if (typeof window.heap !== 'undefined') { return window.heap; }

  function no_op() {}

  var stub = {
    changeInterval: no_op,
    identify: no_op,
    load: no_op,
    setAppId: no_op,
    track: no_op
  };

  var heap = heap || [];
  var site_id = false;

  if (window.location.host && !location.host.match(/(lynr|herokuapp)\.com?$/)) { return stub; }

  heap.load=function(a){window._heapid=a;var b=document.createElement("script");b.type="text/javascript",b.async=!0,b.src=("https:"===document.location.protocol?"https:":"http:")+"//cdn.heapanalytics.com/js/heap.js";var c=document.getElementsByTagName("script")[0];c.parentNode.insertBefore(b,c);var d=function(a){return function(){heap.push([a].concat(Array.prototype.slice.call(arguments,0)))}},e=["identify","track"];for(var f=0;f<e.length;f++)heap[e[f]]=d(e[f])};

  return heap;
});
