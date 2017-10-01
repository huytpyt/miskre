(function() {
  $(document).ready(function() {
    init();
  });

  var init = function () {
    orderPreviewData()
  }

  var orderPreviewData = function() {
    $('#order-table').DataTable( {
      "order": [[ 3, "desc" ]]
    } );
  }
 
}).call(this);
