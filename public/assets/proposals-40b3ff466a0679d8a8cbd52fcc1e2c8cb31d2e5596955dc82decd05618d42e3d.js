(function() {
  $(function() {
    return $("form.new_support").bind("ajax:error", function(event, jqXHR, ajaxSettings, thrownError) {
      if (jqXHR.status === 401) {
        return window.location.replace('/users/sign_in');
      }
    });
  });

}).call(this);
