// Impulsa file upload functionality
// Converted from CoffeeScript to JavaScript

(function() {
  'use strict';

  $(document).on('ready', function() {
    $('.impulsa input[type=file]').each(function(i, element) {
      var $element = $(element);
      var context = $element.closest('.inputlabel-box');

      $element.fileupload({
        url: $('.file', context).data('url'),
        dataType: 'json',
        dropZone: context,
        paramName: 'file',

        drop: function(e, data) {
          $('.file-data .current-file', context).fadeOut(50);
          $('.file-data .progress', context).fadeIn(1);
        },

        change: function(e, data) {
          $('.file-data .current-file', context).fadeOut(50);
          $('.file-data .progress', context).fadeIn(1);
        },

        done: function(e, data) {
          var file = data.result;
          $('.file.input.has-error', context).removeClass('has-error').removeClass('error');
          $('.file-data a.download', context).text(file.name);
          $('.file-data a.download', context).attr('href', file.path);
          $('.file-data a.delete', context).removeClass('hidden');
          $('.file-data .progress', context).fadeOut(50);
          $('.file-data .current-file', context).fadeIn(50);
        },

        fail: function(e, data) {
          var errors = data.jqXHR.responseJSON.map(function(item) {
            return ' * ' + item;
          }).join('\n');
          alert('Han ocurrido los siguientes errores: \n' + errors);
          $('.file-data .progress', context).fadeOut(50);
        },

        progressall: function(e, data) {
          var progress = parseInt(data.loaded / data.total * 100, 10);
          $('.progress .progress-bar', context).css('width', progress + '%');
        }
      });

      $element.prop('disabled', !$.support.fileInput);
      context.addClass($.support.fileInput ? undefined : 'disabled');
    });

    $('.impulsa .file-data a.delete').on('ajax:success', function(e) {
      $(this).closest('.file-data .current-file').fadeOut(50);
    });
  });
})();
