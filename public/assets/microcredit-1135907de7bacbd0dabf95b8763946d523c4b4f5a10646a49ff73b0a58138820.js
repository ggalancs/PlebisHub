(function() {
  var draw_pie_chart, no_towns_html, show_provinces, show_towns;

  draw_pie_chart = function($el, data) {
    var ctx, options, piechart;
    ctx = $el.get(0).getContext("2d");
    options = {
      responsive: true,
      legendTemplate: "",
      percentageInnerCutout: 52,
      animationEasing: "easeInOutCubic"
    };
    return piechart = new Chart(ctx).Pie(data, options);
  };

  show_provinces = function(country_code) {
    $('#microcredit_loan_town').disable_control;
    $('#microcredit_loan_province').disable_control;
    return $('#js-microcredit_loan-province-wrapper').load("/" + window.lang + "/microcreditos/provincias?microcredit_loan_country=" + country_code, function() {
      var prov_select;
      prov_select = $('select#microcredit_loan_province');
      if (prov_select.length > 0 && prov_select.select2) {
        return prov_select.select2({
          formatNoMatches: "No se encontraron resultados"
        });
      } else {
        return show_towns(null);
      }
    });
  };

  no_towns_html = "";

  show_towns = function(country_code, province_code) {
    var has_towns, url;
    $('#microcredit_loan_town').disable_control;
    if (province_code === "-") {
      return;
    }
    if (province_code && country_code === "ES") {
      url = "/" + window.lang + "/microcreditos/municipios?microcredit_loan_country=ES&microcredit_loan_province=" + province_code;
      has_towns = true;
    } else {
      url = "/" + window.lang + "/microcreditos/municipios";
      has_towns = false;
    }
    if (!has_towns && no_towns_html) {
      return $('#js-microcredit_loan-town-wrapper').html(no_towns_html);
    } else {
      return $('#js-microcredit_loan-town-wrapper').load(url, function(response) {
        var options, postal_code, prefix, town_select;
        if (has_towns) {
          town_select = $('select#microcredit_loan_town');
          if (town_select.select2) {
            town_select.select2({
              formatNoMatches: "No se encontraron resultados"
            });
            options = town_select.children("option");
            if (options.length > 1) {
              postal_code = $('#microcredit_loan_postal_code').val;
              prefix = options[1].value.substr(2, 2);
              if (postal_code.length < 5 || postal_code.substr(0, 2) !== prefix) {
                return $('#microcredit_loan_postal_code').val(prefix);
              }
            }
          }
        } else {
          return no_towns_html = response;
        }
      });
    }
  };

  $(function() {
    var color1, color2, country_selector, graph, i, len, parts, ref;
    ref = $(".js-mc-graph");
    for (i = 0, len = ref.length; i < len; i++) {
      graph = ref[i];
      color1 = $(graph).data("color1");
      color2 = $(graph).data("color2");
      parts = [];
      parts.push({
        value: parseInt($('.js-mc-total', graph).html()),
        color: color1,
        highlight: color2,
        label: ""
      });
      parts.push({
        value: parseInt($('.js-mc-pending', graph).html()),
        color: '#eaeaea',
        highlight: color2,
        label: ""
      });
      draw_pie_chart($('canvas', graph), parts);
      $(".hide").hide();
    }
    country_selector = $('select#microcredit_loan_country');
    if (country_selector.length > 0) {
      $.fn.disable_control = function() {
        if (this.data("select2")) {
          this.select2("enable", false).select2("val", "").attr("data-placeholder", "-").select2();
        } else {
          this.prop("disabled", true).val("").attr("placeholder", "-");
        }
        return this;
      };
      country_selector.on("change", function() {
        var country;
        country = $(this).val();
        return show_provinces(country);
      });
      $(document.body).on("change", 'select#microcredit_loan_province', function() {
        return show_towns(country_selector.val(), $(this).val());
      });
    }
    return $(".modal-dialog").each(function() {
      var dialog;
      dialog = $(this);
      $(".close", dialog).on("click", function() {
        return dialog.hide();
      });
      return dialog.show();
    });
  });

}).call(this);
