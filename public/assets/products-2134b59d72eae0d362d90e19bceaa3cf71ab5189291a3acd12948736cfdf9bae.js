(function() {
  Dropzone.autoDiscover = false;

  $(document).ready(function() {
    "myDropzone = new Dropzone('#dz',\n  url: '/products'\n  paramName: 'pict'\n  autoProcessQueue: false\n  uploadMultiple: true\n  parallelUploads: 100\n  maxFiles: 100\n  addRemoveLinks: true\n  hiddenInputContainer: '#dropzone-hidden-input'\n  previewsContainer: '.dropzone-previews'\n)";
    var calculatePrices;
    calculatePrices = function() {
      var product_cost, ship_cost, weight;
      weight = Number($('#product_weight').val());
      ship_cost = 0;
      ship_cost = (function() {
        switch (false) {
          case !(weight <= 60):
            return 3.90;
          case !(weight <= 100):
            return 4.37;
          case !(weight <= 150):
            return 4.96;
          case !(weight <= 200):
            return 5.55;
          case !(weight <= 250):
            return 6.14;
          case !(weight <= 300):
            return 6.72;
          case !(weight <= 350):
            return 7.31;
          case !(weight <= 400):
            return 7.90;
          case !(weight <= 450):
            return 8.49;
          case !(weight <= 500):
            return 9.08;
          case !(weight <= 550):
            return 9.66;
          case !(weight <= 600):
            return 10.25;
          case !(weight <= 650):
            return 10.84;
          case !(weight <= 700):
            return 11.43;
          case !(weight <= 750):
            return 12.02;
          case !(weight <= 800):
            return 12.61;
          case !(weight <= 850):
            return 13.19;
          case !(weight <= 900):
            return 13.78;
          case !(weight <= 950):
            return 14.37;
          case !(weight <= 1000):
            return 14.96;
          default:
            return 20;
        }
      })();
      $('#product_shipping_price').val((ship_cost * 0.2).toFixed(2));
      product_cost = Number($('#product_cost').val());
      $('#product_price').val(product_cost + (ship_cost * 0.8).toFixed(2));
    };
    $('#product_weight,#product_cost').on('change', calculatePrices);
    $('#images-preview').slick({
      dots: true,
      infinite: false,
      speed: 300,
      slidesToShow: 1,
      slidesToScroll: 1,
      centerMode: true,
      centerPadding: '60px',
      variableWidth: true
    });
    $('#product_images').on('change', function() {
      var dvPreview, regex;
      if (typeof FileReader !== 'undefined') {
        dvPreview = $('#dvPreview');
        dvPreview.html('');
        regex = /^([a-zA-Z0-9\s_\\.\-:])+(.jpg|.jpeg|.gif|.png|.bmp)$/;
        $($(this)[0].files).each(function() {
          var file, reader;
          file = $(this);
          if (regex.test(file[0].name.toLowerCase())) {
            reader = new FileReader;
            reader.onload = function(e) {
              var img_container;
              img_container = $("<li class='img-container'><img src= '" + e.target.result + "'/></li>");
              dvPreview.append(img_container);
            };
            reader.readAsDataURL(file[0]);
          } else {
            alert(file[0].name + ' is not a valid image file.');
            dvPreview.html('');
            return false;
          }
        });
      } else {
        alert('This browser does not support HTML5 FileReader.');
      }
    });
  });

}).call(this);
