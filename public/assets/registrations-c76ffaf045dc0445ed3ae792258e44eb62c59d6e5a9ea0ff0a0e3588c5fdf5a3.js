(function() {
  var document_change, has_dni, has_nie, has_passport, init_registrations;

  document_change = function(document_type) {
    $('.js-registration-document-wrapper').removeClass('invisible');
    $('.js-registration-document-wrapper label').html(document_type + " <abbr title='required'>*</abbr>");
    switch (document_type) {
      case "DNI":
        return has_dni();
      case "NIE":
        return has_nie();
      case "Pasaporte":
        return has_passport();
      default:
        return has_dni();
    }
  };

  has_dni = function() {
    $('.js-registration-document-passport').addClass('invisible');
    $('.js-registration-document-nie').addClass('invisible');
    return $('.js-registration-document-dni').removeClass('invisible');
  };

  has_nie = function() {
    $('.js-registration-document-passport').addClass('invisible');
    $('.js-registration-document-dni').addClass('invisible');
    return $('.js-registration-document-nie').removeClass('invisible');
  };

  has_passport = function() {
    $('.js-registration-document-dni').addClass('invisible');
    $('.js-registration-document-nie').addClass('invisible');
    return $('.js-registration-document-passport').removeClass('invisible');
  };

  init_registrations = function() {
    var document_type;
    if ($('.js-registration-document:checked').length > 0) {
      document_type = $('.js-registration-document:checked').find('option:selected').text();
      document_change(document_type);
    }
    return $('.js-registration-document').change(function(event) {
      document_type = $(this).find('option:selected').text();
      return document_change(document_type);
    });
  };

  $(window).bind('page:change', function() {
    return init_registrations();
  });

  $(function() {
    return init_registrations();
  });

}).call(this);
