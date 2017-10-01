(function() {
  $(document).ready(function() {
    init();
  });

  var init = function () {
    $.getJSON("reports/product_orders_unfulfilled.json", function (result) {
      ProductOrdersUnfulfilled(result)
    });
  }

  var ProductOrdersUnfulfilled = function(data) {
    var chart = new CanvasJS.Chart("products-order-unfulfilled", {
      theme: "light1", // "light2", "dark1", "dark2"
      animationEnabled: false, // change to true    
      title:{
        text: "Products in orders unfulfilled "
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
