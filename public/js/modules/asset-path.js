define(['modules/data-attrs'], function(data) {
  var assetPath = false;

  return function() {
    if (assetPath === false) {
      assetPath = data.get(document.body, 'asset-path');
    }
    return assetPath;
  };
});
