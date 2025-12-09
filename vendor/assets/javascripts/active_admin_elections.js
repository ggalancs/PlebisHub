// Active Admin elections functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  function updateHeader(header) {
    if (header.checked) {
      $(header).closest('li.choice').addClass('checked');
    } else {
      $(header).closest('li.choice').removeClass('checked');
    }
  }

  function updateHeaders() {
    $('.options_headers li.choice input').each(function() {
      updateHeader(this);
    });
  }

  $(document).ready(function() {
    updateHeaders();

    $(document).on('cocoon:after-insert', function(e, insertedItem) {
      updateHeaders();
    });

    $(document).on('click', '.options_headers li.choice input', function() {
      updateHeader(this);
    });

    $(document).on('click', 'a[data-presets]', function() {
      var p = $(this).closest('li');
      p.next().children('.enable_tabs').val($(this).data('presets').replace(/\|/g, '\n'));
      $('li.choice input', p.prev()).each(function() {
        this.checked = (this.value === 'Text');
        updateHeader(this);
      });
      return false;
    });
  });

  // D3 Election graph
  $(document).ready(function() {
    $('.js-election-graph').each(function() {
      var graph = $(this);

      d3.json(graph.data('url'), function(error, data) {
        if (error) {
          throw error;
        }

        var padding = 50;
        var height = graph.data('height');
        var width = graph.parent().width();
        var xlimits = data.limits[0];
        var ylimits = data.limits[1];

        var x = d3.scaleTime()
          .domain([new Date(xlimits[0] * 1000), new Date(xlimits[1] * 1000)])
          .range([padding, width - padding]);

        var y = d3.scaleTime()
          .domain([new Date(ylimits[1] * 1000), new Date(ylimits[0] * 1000)])
          .range([padding, height - padding]);

        var z = d3.scaleSequential(d3.interpolateWarm);

        var svg = d3.select(graph.get(0));
        svg.attr('width', width).attr('height', height);

        svg.append('g')
          .attr('transform', 'translate(' + padding + ',0)')
          .call(d3.axisLeft(y));

        svg.append('g')
          .attr('transform', 'translate(0, ' + (height - padding) + ')')
          .call(d3.axisBottom(x));

        svg.append('g')
          .selectAll('circle')
          .data(data.data)
          .enter()
          .append('circle')
          .attr('r', 1)
          .attr('cx', function(d) {
            return x(new Date(d[0] * 1000));
          })
          .attr('cy', function(d) {
            return y(new Date(d[1] * 1000));
          })
          .attr('fill', function(d) {
            return z(1.0 * d[2] / (d[2] + 7));
          });
      });
    });
  });
})();
