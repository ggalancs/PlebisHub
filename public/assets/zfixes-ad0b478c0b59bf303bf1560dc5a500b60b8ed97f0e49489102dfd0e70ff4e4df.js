(function() {
  var born_at_format, init_zfixes;

  born_at_format = function() {
    if ($('#select2-chosen-2').html() === ".col-xs-3") {
      $('#select2-chosen-2').html('día');
    }
    if ($('#select2-chosen-3').html() === ".col-xs-5") {
      $('#select2-chosen-3').html('mes');
    }
    if ($('#select2-chosen-4').html() === ".col-xs-4") {
      return $('#select2-chosen-4').html('año');
    }
  };

  init_zfixes = function() {
    return born_at_format();
  };

  $(window).bind('page:change', function() {
    return init_zfixes();
  });

  $(function() {
    return init_zfixes();
  });

}).call(this);
