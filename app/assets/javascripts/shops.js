(function() {
  $(document).ready(function() {
    init();
  });

  var init = function () {
    $.getJSON("supply_orders_unfulfilled.json", function (result) {
      SupplyOrdersUnfulfilled(result)
    });
  }

  var SupplyOrdersUnfulfilled = function(data) {
    var chart = new CanvasJS.Chart("supplies-order-unfulfilled", {
      theme: "light1", // "light2", "dark1", "dark2"
      animationEnabled: false, // change to true    
      title:{
        text: "Supplies in orders unfulfilled "
      },
      data: [
      {
        // Change type to "bar", "area", "spline", "pie",etc.
        type: "column",
        dataPoints: data
      }
      ]
    });
    chart.render();

  }
 
}).call(this);
