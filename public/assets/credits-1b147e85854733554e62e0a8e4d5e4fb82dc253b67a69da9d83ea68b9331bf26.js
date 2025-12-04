(function() {
  var colors, draw_pie_chart;

  colors = ['#c3a6cf', '#954e99', '#612d62', '#97c2b8', '#269283'];

  draw_pie_chart = function($el, data, template) {
    var ctx, options, piechart;
    ctx = $el.get(0).getContext("2d");
    options = {
      legendTemplate: template,
      percentageInnerCutout: 50,
      animationEasing: "easeInOutCubic"
    };
    piechart = new Chart(ctx).Pie(data, options);
    return $el.after(piechart.generateLegend());
  };

  $(function() {
    var graph, i, len, parts, ref, results, v, vs;
    ref = $(".js-col-total-graph");
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      graph = ref[i];
      vs = $('.js-col-total', graph);
      parts = (function() {
        var j, len1, results1;
        results1 = [];
        for (j = 0, len1 = vs.length; j < len1; j++) {
          v = vs[j];
          results1.push({
            value: parseInt($(v).html()),
            color: colors[Math.round(2 * _i / vs.length)],
            highlight: colors[0],
            label: $(v).attr("alt")
          });
        }
        return results1;
      })();
      parts.unshift({
        value: parseInt($('.js-col-pending').html()),
        color: '#eeeeee',
        highlight: colors[3],
        label: $('.js-col-pending').attr("alt")
      });
      draw_pie_chart($('canvas', graph), parts, "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"><%if(segments[i].label){%><%=segments[i].label%></span><%}%></li><%}%></ul>");
      results.push($(".hide").hide());
    }
    return results;
  });

}).call(this);
