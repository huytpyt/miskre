(function() {
  $(document).ready(function() {
    init();
  });

  var init = function () {
    dataTableRequest();
  }

  var dataTableRequest = function() {
    $('table.requested-products').DataTable( {
      destroy: true,
      "order": [[ 0, "desc" ]]
    } );
  }
 
}).call(this);
