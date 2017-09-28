(function() {
  $(document).ready(function() {
    init();
  });

  var init = function () {
    multiSelect();
    navTab();
    dataTable()
  }

  var dataTable = function() {
    $('#product-table, #my-product-table').DataTable( {
      destroy: true,
      "order": [[ 0, "asc" ]]
    } );
  }
  var multiSelect = function() {
    $('.chosen-select').chosen();
  }

  var navTab = function() {

    $('ul.tabs li').on("click", function(){
      var tab_id = $(this).attr('data-tab');

      $('ul.tabs li').removeClass('current');
      $('.tab-content').removeClass('current');

      $(this).addClass('current');
      $("#"+tab_id).addClass('current');
    });
  }
}).call(this);
