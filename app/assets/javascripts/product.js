(function() {
  $(document).ready(function() {
    init();
  });

  var init = function () {
    multiSelect();
  }

  var multiSelect = function() {
    $('.chosen-select').chosen();
  }
}).call(this);
