// Credits/Collaboration pie chart functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  var colors = ['#c3a6cf', '#954e99', '#612d62', '#97c2b8', '#269283'];

  function drawPieChart($el, data, template) {
    var ctx = $el.get(0).getContext('2d');
    var options = {
      legendTemplate: template,
      percentageInnerCutout: 50,
      animationEasing: 'easeInOutCubic'
    };
    var piechart = new Chart(ctx).Pie(data, options);
    $el.after(piechart.generateLegend());
  }

  $(document).ready(function() {
    $('.js-col-total-graph').each(function(index, graph) {
      var vs = $('.js-col-total', graph);
      var parts = [];

      // Add pending amount first
      parts.push({
        value: parseInt($('.js-col-pending').html(), 10),
        color: '#eeeeee',
        highlight: colors[3],
        label: $('.js-col-pending').attr('alt')
      });

      // Add total amounts
      vs.each(function(i, v) {
        parts.push({
          value: parseInt($(v).html(), 10),
          color: colors[Math.round(2 * i / vs.length)],
          highlight: colors[0],
          label: $(v).attr('alt')
        });
      });

      var template = '<ul class="<%=name.toLowerCase()%>-legend">' +
        '<% for (var i=0; i<segments.length; i++){%>' +
        '<li><span style="background-color:<%=segments[i].fillColor%>">' +
        '<%if(segments[i].label){%><%=segments[i].label%></span><%}%></li>' +
        '<%}%></ul>';

      drawPieChart($('canvas', graph), parts, template);

      $('.hide').hide();
    });
  });
})();
