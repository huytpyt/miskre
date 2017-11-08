(function() {
  $(document).ready(function() {
    init();
  });

  var init = function () {
    multiSelect();
    navTab();
    dataTable()
    createChart();
    xDatePicker();
    submitDateChoosen();
    selectCountry();
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

  var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
  };

  var xDatePicker = function() {
    var startDate = getUrlParameter('start');
    if (startDate == undefined) {
      var dNow = new Date();
      dNow.setDate(dNow.getDate() - 7);
      startDate = dNow.getDate() + "/" + (dNow.getMonth() + 1) + "/" + dNow.getFullYear()
    }
    var endDate = getUrlParameter('end');
    $('input[name="daterange"]').daterangepicker({
      "startDate": startDate,
      "endDate": endDate,
      locale: {
        format: 'DD/MM/YYYY'
      }
    });
  }

  var submitDateChoosen = function() {
    $(".applyBtn").on("click", function() {
      var startDate = $("input[name=daterangepicker_start]").val();
      var endDate = $("input[name=daterangepicker_end]").val();
      location.href = "?start="+startDate+"&end="+endDate;
    })
  }

  var createChart = function() {
    var startDate = getUrlParameter('start');
    var endDate = getUrlParameter('end');
    var dataPoints = [];
    if ($("#tracking-product-chart").length >0) {
      $.getJSON("tracking_product?start=" + startDate + "&end=" + endDate, function (result) {
        $.each(result, function(key, value){
          dataPoints.push({x: new Date(value.x), y: value.y});
        });
        OHLCChart(dataPoints)
      });
    }
  }
  var OHLCChart = function(data) {
    var dataPoints = [];
    var chart = new CanvasJS.Chart("tracking-product-chart", {
      animationEnabled: true,
      title:{
        text: "Tracking Product Quantity Chart"
      },
      axisX: {
        interval:1,
        intervalType: "day",
        valueFormatString: "DD MMM"
      },
      axisY: {
        includeZero:false,
        prefix: "",
        title: "Quantity"
      },
      data: [{
        type: "ohlc",
        yValueFormatString: "###", 
        xValueFormatString: "DD MMM YYYY",
        dataPoints: data
      }]
    });
    chart.render();
  }

  var selectCountry =  function() {
    $(".chosen-select-country").chosen().change(function (event) {
      country = $(event.target).val();
      //history.pushState(null, null, '/products?c=' + country);
      window.location.search = '&nation=' + country;
    });
  }

}).call(this);
