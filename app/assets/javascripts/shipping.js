(function() {
  $(document).ready(function() {
    init();
  });

  var init = function () {
    markInfinity();
    dataTable();
  }

  var dataTable = function() {
    $('table.shipping-manager').DataTable( {
      destroy: true,
      "order": [[ 0, "asc" ]]
    } );
  }

  var markInfinity = function() {
    if ($("input[name=mark_infinity]").prop("checked") == true) {
      $("#shipping_setting_max_price").prop("disabled", "disabled");
      $("#shipping_setting_max_price").val("infinity")
    }
    var original_value = $("#shipping_setting_max_price").val();
    $("input[name=mark_infinity]").on("click", function() {
       if ($(this).prop("checked") == true) {
          $("#shipping_setting_max_price").prop("disabled", "disabled");
          $("#shipping_setting_max_price").val("infinity")
        }
        else {
          $("#shipping_setting_max_price").prop("disabled", "");
          $("#shipping_setting_max_price").val(original_value);
        }
    });
  }

}).call(this);


