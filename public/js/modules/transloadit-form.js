define(['jquery', 'jquery.transloadit', 'modules/spinner'], function($, jtl, spinner) {

  var baseTransloaditOpts = {
    autoSubmit: false,
    fields: 'input[name=idx], input[name=dealership_id]',
    modal: false,
    triggerUploadOnFileSelection: true,
    onStart: uploadStart,
    wait: true
  };

  var spinners = {};

  function init(els) {
    var forms = $(els);
    forms.each(function() {
      var form = $(this);
      var opts = transloaditOpts(form.data('image-type'));
      form.transloadit(opts);
    });
  }

  function handleFileSelect(evt) {
    var files = evt.target.files; // FileList object

    // files is a FileList of File objects. List some properties.
    var output = [];
    for (var i = 0, f; f = files[i]; i++) {
      output.push('<li><strong>', escape(f.name), '</strong> (', f.type || 'n/a', ') - ',
                  f.size, ' bytes, last modified: ',
                  f.lastModifiedDate ? f.lastModifiedDate.toLocaleDateString() : 'n/a',
                  '</li>');
    }
    document.getElementById('list').innerHTML = '<ul>' + output.join('') + '</ul>';
  }

  function transloaditOpts(page) {
    var specific;
    switch (page) {
      case 'vehicle':
        specific = {
          onSuccess: uploadPhotosSuccess,
          fields: 'input[name=idx], input[name=dealership_id], input[name=vehicle_id]'
        };
        break;
      case 'account':
        specific = { onSuccess: uploadAccountSuccess };
        break;
      default:
        specific = {};
        break;
    }
    return $.extend({}, baseTransloaditOpts, specific);
  }

  function uploadAccountSuccess(assembly) {
    uploadSuccessStopSpinner(assembly);
    var results = assembly.results;
    var input = $('input[name=image]');
    var original = results[':original'][0];
    var full = results.optimized_full[0];
    var thumb = results.optimized_thumb[0];
    var image = {
      url: full.url,
      src: full.url,
      width: full.meta.width,
      height: full.meta.height
    };
    input.val(JSON.stringify(image));
    $('img.f-image-preview').attr(image).removeClass('f-image-preview-empty icon-add-photo');
  }

  function uploadPhotosSuccess(assembly) {
    uploadSuccessStopSpinner(assembly);
    var results = assembly.results;
    var fields = assembly.fields;
    var form = $('#photo-' + fields.idx);
    var input = $('input[name=images]');
    var original = results[':original'][0];
    var full = results.optimized_full[0];
    var thumb = results.optimized_thumb[0];
    var image = {
      original: {
        url: original.url,
        src: original.url,
        width: original.meta.width,
        height: original.meta.height
      },
      full: {
        url: full.url,
        src: full.url,
        width: full.meta.width,
        height: full.meta.height
      },
      thumb: {
        url: thumb.url,
        src: thumb.url,
        width: thumb.meta.width,
        height: thumb.meta.height
      }
    };
    var images = JSON.parse(input.val());
    images[fields.idx] = image;
    input.val(JSON.stringify(images));
    form.find('img.f-image-preview').attr(image.full).removeClass('f-image-preview-empty icon-add-photo');
  }

  function uploadStart(assembly) {
    var fields = assembly.fields;
    var form = $('#photo-' + fields.idx);
    var spin = form.data('spinner') || spinner(form.find('.fs-image')[0]);
    form.data('spinner', spin);
    spinners[fields.idx] = spin;
  }

  function uploadSuccessStopSpinner(assembly) {
    var fields = assembly.fields;
    var form = $('#photo-' + fields.idx);
    var spinner = form.data('spinner');
    if (spinner && typeof spinner.stop === 'function') { form.data('spinner').stop(); }
  }

  return init;

});
