// Z-fixes: Workarounds for various bugs
// Converted from CoffeeScript to JavaScript
//
// FIX: Overriding select2 placeholder bug with Formtastic-Bootstrap
// https://github.com/mjbellantoni/formtastic-bootstrap/issues/80
// If this isn't here, then you'll see ".col-xs-3 .col-xs-5 .col-xs-4" as placeholders

(function() {
  'use strict';

  function bornAtFormat() {
    if ($('#select2-chosen-2').html() === '.col-xs-3') {
      $('#select2-chosen-2').html('día');
    }
    if ($('#select2-chosen-3').html() === '.col-xs-5') {
      $('#select2-chosen-3').html('mes');
    }
    if ($('#select2-chosen-4').html() === '.col-xs-4') {
      $('#select2-chosen-4').html('año');
    }
  }

  function initZfixes() {
    bornAtFormat();
  }

  $(document).ready(function() {
    initZfixes();
  });

  // Support for page navigation
  $(document).on('turbo:load', function() {
    initZfixes();
  });
})();
