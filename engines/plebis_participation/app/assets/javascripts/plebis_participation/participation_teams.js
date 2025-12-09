// Participation teams toggle functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  $(document).ready(function() {
    $('.show_info').on('click', function(event) {
      $('.show_info').hide();
      $('#participation_teams').hide();
      $('.show_teams').show();
      $('#participation_teams_info').show();
      event.preventDefault();
    });

    $('.show_teams').on('click', function(event) {
      $('.show_teams').hide();
      $('#participation_teams_info').hide();
      $('.show_info').show();
      $('#participation_teams').show();
      event.preventDefault();
    });

    // Initial state
    if ($('.show_info').length) {
      $('.show_teams').hide();
      $('#participation_teams_info').hide();
    }
  });
})();
