// Active Admin microcredits functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  function getTotals() {
    var totals = 0;
    $('.single_limits').each(function() {
      var $item = $(this);
      totals += $item.data('amount') * parseInt($item.val(), 10);
    });
    return totals;
  }

  $(document).ready(function() {
    var microcreditPhaseLimitAmount = $('#microcredit_phase_limit_amount');

    if (microcreditPhaseLimitAmount.length > 0) {
      microcreditPhaseLimitAmount.val(getTotals());

      $('.single_limits').on('change', function() {
        microcreditPhaseLimitAmount.val(getTotals());
      });
    }
  });
})();
