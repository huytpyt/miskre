$(document).ready(function(){
  // $('#product-table').DataTable();
  $('#order-table').DataTable( {
    "order": [[ 3, "desc" ]]
  } );
});
