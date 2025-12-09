// Active Admin spam filter functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  function loadFilterUsers(offset, total, progressLabel, usersDiv) {
    var limit = 1000;

    $.ajax({
      url: 'more?offset=' + offset + '&limit=' + limit
    }).done(function(response) {
      usersDiv.append(response);
      offset += limit;

      if (offset >= total) {
        progressLabel.text(total);
      } else {
        progressLabel.text(offset);
        loadFilterUsers(offset, total, progressLabel, usersDiv);
      }
    });
  }

  $(document).ready(function() {
    var spamFilterProgress = $('#js-spam-filter-progress');

    if (spamFilterProgress.length > 0) {
      var spamFilterUsers = $('#js-spam-filter-users');
      var spamFilterTotal = parseInt($('#js-spam-filter-total').text(), 10);
      loadFilterUsers(0, spamFilterTotal, spamFilterProgress, spamFilterUsers);
    }
  });
})();
