(function() {
  var calculate_collaboration, change_payment_type, init_collaborations;

  calculate_collaboration = function() {
    var $amount, $freq, message, total;
    $amount = $('.js-collaboration-amount option:selected');
    $freq = $('.js-collaboration-frequency option:selected');
    if (($amount.index() > 0) && ($freq.index() > 0)) {
      total = $amount.val() / 100.0 * $freq.val();
      switch ($freq.val()) {
        case "1":
          message = total + " € cada mes, en total " + total * 12 + " € al año";
          break;
        case "3":
          message = total + " € cada 3 meses, en total " + total * 4 + " € al año";
          break;
        case "12":
          message = total + " € cada año en un pago único anual";
      }
      $('.js-collaboration-alert').show();
      return $('#js-collaboration-alert-amount').text(message);
    } else {
      return $('.js-collaboration-alert').hide();
    }
  };

  change_payment_type = function(type) {
    switch (type) {
      case "2":
        $('.js-collaboration-type-form-3').hide();
        return $('.js-collaboration-type-form-2').show('slide');
      case "3":
        $('.js-collaboration-type-form-2').hide();
        return $('.js-collaboration-type-form-3').show('slide');
      default:
        $('.js-collaboration-type-form-2').hide();
        return $('.js-collaboration-type-form-3').hide();
    }
  };

  init_collaborations = function() {
    var must_reload;
    must_reload = $('#js-must-reload');
    if (must_reload) {
      if (must_reload.val() !== "1") {
        $("form").on('submit', function(event) {
          must_reload.val("1");
          return $("#js-confirm-button").hide();
        });
      } else {
        must_reload.val("0");
        $("#js-confirm-button").hide();
        location.reload();
      }
    }
    change_payment_type($('.js-collaboration-type').val() || $('.js-collaboration-type').select2('val'));
    $('.js-collaboration-type').on('change', function(event) {
      var type;
      type = $(this).val();
      return change_payment_type(type);
    });
    calculate_collaboration();
    return $('.js-collaboration-amount, .js-collaboration-frequency').on('change', function() {
      return calculate_collaboration();
    });
  };

  $(window).bind('page:change', function() {
    return init_collaborations();
  });

  $(function() {
    return init_collaborations();
  });

}).call(this);
