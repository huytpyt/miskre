$(document).ready(function(){
  // $('#product-table').DataTable();
  $('#product-table').DataTable( {
    destroy: true,
    "order": [[ 0, "asc" ]]
  } );
});
