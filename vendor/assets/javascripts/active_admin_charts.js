// Active Admin charts functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  function all(i, alpha) {
    var colors = ['195,166,207', '149,78,153', '97,45,98', '38,146,131', '151,194,184', '100,100,100'];
    return 'rgba(' + colors[i % 6] + ',' + alpha + ')';
  }

  function purple(i, alpha) {
    var colors = ['195,166,207', '149,78,153', '97,45,98'];
    return 'rgba(' + colors[i % 3] + ',' + alpha + ')';
  }

  function green(i, alpha) {
    var colors = ['38,146,131', '151,194,184'];
    return 'rgba(' + colors[i % 2] + ',' + alpha + ')';
  }

  // Helper to parse formatted numbers
  function toInt(str) {
    return parseInt(str.replace(/€/g, '').replace(/\./g, '').replace(/,/g, '.').trim(), 10);
  }

  function drawChart($el) {
    var ctx = $el.get(0).getContext('2d');
    var scope = $el.data('scope');
    var pie = $el.hasClass('js-pie');

    var options = {
      percentageInnerCutout: 20,
      animationEasing: 'easeInOutCubic',
      bezierCurveTension: 0.2,
      responsive: true
    };

    var graphData = $('.js-' + scope);
    var chart = null;
    var data;

    if (pie) {
      data = [];
      $('.js-cell', graphData).each(function(i, cell) {
        data.push({
          value: toInt($(cell).text()),
          color: purple(i, 1.0),
          highlight: green(0, 1.0),
          label: $(cell).data('label')
        });
      });

      options.legendTemplate = '<ul style="list-style-type: none;" class="<%=name.toLowerCase()%>-legend">' +
        '<% for (var i=0; i<segments.length; i++){%>' +
        '<li><span style="background-color:<%=segments[i].fillColor%>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>' +
        '&nbsp;&nbsp;<%if(segments[i].label){%><%=segments[i].label%> (<%=segments[i].value%>)<%}%></li>' +
        '<%}%></ul>';

      chart = new Chart(ctx).Pie(data, options);
    } else {
      var series = [];
      $('.js-serie', graphData).each(function(index, serie) {
        series.push($(serie).data('label') || $(serie).text());
      });

      var grid = [];
      $('.js-row', graphData).each(function(rowIndex, row) {
        var rowData = [];
        $('.js-cell', row).each(function(cellIndex, cell) {
          rowData.push(toInt($(cell).text()));
        });
        grid.push(rowData);
      });

      // Transpose grid to get series data
      var seriesData = grid[0].map(function(col, i) {
        return grid.map(function(row) {
          return row[i];
        });
      });

      var datasets = series.map(function(serie, i) {
        return {
          label: serie,
          fillColor: all(i, 0.2),
          strokeColor: all(i, 1.0),
          pointColor: all(i, 1.0),
          pointStrokeColor: '#fff',
          pointHighlightFill: '#fff',
          pointHighlightStroke: all(i, 1.0),
          data: seriesData[i]
        };
      });

      var labels = [];
      $('.js-label', graphData).each(function(index, label) {
        labels.push($(label).text().trim());
      });

      data = {
        labels: labels,
        datasets: datasets
      };

      options.legendTemplate = '<ul style="list-style-type: none;" class="<%=name.toLowerCase()%>-legend">' +
        '<% for (var i=0; i<datasets.length; i++){%>' +
        '<li><span style="background-color:<%=datasets[i].strokeColor%>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>' +
        '&nbsp;&nbsp;<%if(datasets[i].label){%><%=datasets[i].label%><%}%></li>' +
        '<%}%></ul>';

      chart = new Chart(ctx).Line(data, options);
    }

    $el.after(chart.generateLegend());
  }

  $(document).ready(function() {
    $('.js-graph').each(function() {
      drawChart($(this));
    });
  });
})();
