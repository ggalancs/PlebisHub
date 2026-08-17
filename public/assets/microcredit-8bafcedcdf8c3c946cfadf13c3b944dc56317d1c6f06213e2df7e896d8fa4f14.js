// Microcredit form functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  var noTownsHtml = '';

  function drawPieChart($el, data) {
    var ctx = $el.get(0).getContext('2d');
    var options = {
      responsive: true,
      legendTemplate: '',
      percentageInnerCutout: 52,
      animationEasing: 'easeInOutCubic'
    };
    new Chart(ctx).Pie(data, options);
  }

  function showProvinces(countryCode) {
    $('#microcredit_loan_town').disable_control();
    $('#microcredit_loan_province').disable_control();

    var url = '/' + window.lang + '/microcreditos/provincias?microcredit_loan_country=' + countryCode;
    $('#js-microcredit_loan-province-wrapper').load(url, function() {
      var provSelect = $('select#microcredit_loan_province');
      if (provSelect.length > 0 && provSelect.select2) {
        provSelect.select2({ formatNoMatches: 'No se encontraron resultados' });
      } else {
        showTowns(null);
      }
    });
  }

  function showTowns(countryCode, provinceCode) {
    $('#microcredit_loan_town').disable_control();

    if (provinceCode === '-') {
      return;
    }

    var url;
    var hasTowns;

    if (provinceCode && countryCode === 'ES') {
      url = '/' + window.lang + '/microcreditos/municipios?microcredit_loan_country=ES&microcredit_loan_province=' + provinceCode;
      hasTowns = true;
    } else {
      url = '/' + window.lang + '/microcreditos/municipios';
      hasTowns = false;
    }

    if (!hasTowns && noTownsHtml) {
      $('#js-microcredit_loan-town-wrapper').html(noTownsHtml);
    } else {
      $('#js-microcredit_loan-town-wrapper').load(url, function(response) {
        if (hasTowns) {
          var townSelect = $('select#microcredit_loan_town');
          if (townSelect.select2) {
            townSelect.select2({ formatNoMatches: 'No se encontraron resultados' });
            var options = townSelect.children('option');
            if (options.length > 1) {
              var postalCode = $('#microcredit_loan_postal_code').val();
              var prefix = options[1].value.substr(2, 2);
              if (postalCode.length < 5 || postalCode.substr(0, 2) !== prefix) {
                $('#microcredit_loan_postal_code').val(prefix);
              }
            }
          }
        } else {
          noTownsHtml = response;
        }
      });
    }
  }

  $(document).ready(function() {
    // Initialize pie charts
    $('.js-mc-graph').each(function(index, graph) {
      var color1 = $(graph).data('color1');
      var color2 = $(graph).data('color2');
      var parts = [];

      parts.push({
        value: parseInt($('.js-mc-total', graph).html(), 10),
        color: color1,
        highlight: color2,
        label: ''
      });

      parts.push({
        value: parseInt($('.js-mc-pending', graph).html(), 10),
        color: '#eaeaea',
        highlight: color2,
        label: ''
      });

      drawPieChart($('canvas', graph), parts);
      $('.hide').hide();
    });

    // Country/Province/Town selectors
    var countrySelector = $('select#microcredit_loan_country');
    if (countrySelector.length > 0) {
      // Add disable_control helper to jQuery
      $.fn.disable_control = function() {
        if (this.data('select2')) {
          this.select2('enable', false).select2('val', '').attr('data-placeholder', '-').select2();
        } else {
          this.prop('disabled', true).val('').attr('placeholder', '-');
        }
        return this;
      };

      countrySelector.on('change', function() {
        var country = $(this).val();
        showProvinces(country);
      });

      $(document.body).on('change', 'select#microcredit_loan_province', function() {
        showTowns(countrySelector.val(), $(this).val());
      });
    }

    // Modal dialogs
    $('.modal-dialog').each(function() {
      var dialog = $(this);
      $('.close', dialog).on('click', function() {
        dialog.hide();
      });
      dialog.show();
    });
  });
})();
