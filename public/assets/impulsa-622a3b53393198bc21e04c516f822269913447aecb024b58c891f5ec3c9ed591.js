(function() {
  $(document).on('ready', function() {
    $('.impulsa input[type=file]').each(function(i, element) {
      var $element, context, ref;
      $element = $(element);
      context = $element.closest(".inputlabel-box");
      $element.fileupload({
        url: $(".file", context).data("url"),
        dataType: 'json',
        dropZone: context,
        paramName: 'file',
        drop: function(e, data) {
          $(".file-data .current-file", context).fadeOut(50);
          return $(".file-data .progress", context).fadeIn(1);
        },
        change: function(e, data) {
          $(".file-data .current-file", context).fadeOut(50);
          return $(".file-data .progress", context).fadeIn(1);
        },
        done: function(e, data) {
          var file;
          file = data.result;
          $(".file.input.has-error", context).removeClass("has-error").removeClass("error");
          $(".file-data a.download", context).text(file.name);
          $(".file-data a.download", context).attr("href", file.path);
          $(".file-data a.delete", context).removeClass("hidden");
          $('.file-data .progress', context).fadeOut(50);
          return $(".file-data .current-file", context).fadeIn(50);
        },
        fail: function(e, data) {
          alert("Han ocurrido los siguientes errores: \n" + data.jqXHR.responseJSON.map(function(i) {
            return " * " + i;
          }).join("\n"));
          return $('.file-data .progress', context).fadeOut(50);
        },
        progressall: function(e, data) {
          var progress;
          progress = parseInt(data.loaded / data.total * 100, 10);
          return $('.progress .progress-bar', context).css('width', progress + '%');
        }
      });
      $element.prop('disabled', !$.support.fileInput);
      return context.addClass((ref = $.support.fileInput) != null ? ref : {
        undefined: 'disabled'
      });
    });
    return $(".impulsa .file-data a.delete").on("ajax:success", function(e) {
      return $(this).closest(".file-data .current-file").fadeOut(50);
    });
  });

}).call(this);
