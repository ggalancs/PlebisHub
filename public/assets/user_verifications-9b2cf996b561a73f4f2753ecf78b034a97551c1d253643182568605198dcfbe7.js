// User verification image preview functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  function initUserVerifications() {
    $('.js-user-verification input').on('change', function() {
      var input = this;
      if (input.files && input.files[0]) {
        var reader = new FileReader();
        var $image = $('.' + input.id + ' img');

        reader.onload = function(e) {
          $image.attr('src', e.target.result);
        };

        reader.readAsDataURL(input.files[0]);
      }
    });
  }

  $(document).ready(function() {
    initUserVerifications();
  });
})();
