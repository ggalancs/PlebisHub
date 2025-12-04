(function() {
  var init_user_verifications;

  init_user_verifications = function() {
    return $(".js-user-verification input").bind("change", function() {
      var reader;
      if (this.files && this.files[0]) {
        reader = new FileReader();
        reader.image = jQuery("." + this.id + " img");
        reader.onload = function(e) {
          return this.image.attr('src', e.target.result);
        };
        return reader.readAsDataURL(this.files[0]);
      }
    });
  };

  $(function() {
    return init_user_verifications();
  });

}).call(this);
