// Collaboration form functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  function calculateCollaboration() {
    var $amount = $('.js-collaboration-amount option:selected');
    var $freq = $('.js-collaboration-frequency option:selected');

    if ($amount.index() > 0 && $freq.index() > 0) {
      var total = $amount.val() / 100.0 * $freq.val();
      var message;

      switch ($freq.val()) {
        case '1':
          message = total + ' € cada mes, en total ' + (total * 12) + ' € al año';
          break;
        case '3':
          message = total + ' € cada 3 meses, en total ' + (total * 4) + ' € al año';
          break;
        case '12':
          message = total + ' € cada año en un pago único anual';
          break;
      }

      $('.js-collaboration-alert').show();
      $('#js-collaboration-alert-amount').text(message);
    } else {
      $('.js-collaboration-alert').hide();
    }
  }

  function changePaymentType(type) {
    switch (type) {
      case '2':
        $('.js-collaboration-type-form-3').hide();
        $('.js-collaboration-type-form-2').show('slide');
        break;
      case '3':
        $('.js-collaboration-type-form-2').hide();
        $('.js-collaboration-type-form-3').show('slide');
        break;
      default:
        $('.js-collaboration-type-form-2').hide();
        $('.js-collaboration-type-form-3').hide();
    }
  }

  function initCollaborations() {
    var mustReload = $('#js-must-reload');

    if (mustReload.length) {
      if (mustReload.val() !== '1') {
        $('form').on('submit', function(event) {
          mustReload.val('1');
          $('#js-confirm-button').hide();
        });
      } else {
        mustReload.val('0');
        $('#js-confirm-button').hide();
        location.reload();
      }
    }

    var paymentType = $('.js-collaboration-type').val() ||
                      ($('.js-collaboration-type').data('select2') ?
                       $('.js-collaboration-type').select2('val') : null);
    changePaymentType(paymentType);

    $('.js-collaboration-type').on('change', function(event) {
      var type = $(this).val();
      changePaymentType(type);
    });

    calculateCollaboration();
    $('.js-collaboration-amount, .js-collaboration-frequency').on('change', function() {
      calculateCollaboration();
    });
  }

  // Initialize on page load and navigation
  $(document).ready(function() {
    initCollaborations();
  });

  // Support for page navigation (if using Turbo/Turbolinks-like behavior)
  $(document).on('turbo:load', function() {
    initCollaborations();
  });
})();
