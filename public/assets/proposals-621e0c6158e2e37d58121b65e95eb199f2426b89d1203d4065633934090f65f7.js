// Proposals support form functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  $(document).ready(function() {
    $('form.new_support').on('ajax:error', function(event, jqXHR, ajaxSettings, thrownError) {
      if (jqXHR.status === 401) {
        window.location.replace('/users/sign_in');
      }
    });
  });
})();
