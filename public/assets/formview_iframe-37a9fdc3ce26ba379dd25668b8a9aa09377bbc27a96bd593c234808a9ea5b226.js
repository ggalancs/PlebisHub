// Formview iframe resizer
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  $(document).ready(function() {
    var iframe = $('#formview_iframe');
    if (iframe.length && typeof iframe.iFrameResize === 'function') {
      iframe.iFrameResize();
    }
  });
})();
