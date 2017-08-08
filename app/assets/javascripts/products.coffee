# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

Dropzone.autoDiscover = false
   
$(document).ready ->
  
  """
  myDropzone = new Dropzone('#dz',
    url: '/products'
    paramName: 'pict'
    autoProcessQueue: false
    uploadMultiple: true
    parallelUploads: 100
    maxFiles: 100
    addRemoveLinks: true
    hiddenInputContainer: '#dropzone-hidden-input'
    previewsContainer: '.dropzone-previews'
  )
  """

  calculatePrices = ->
    weight  = Number($('#product_weight').val());
    ship_cost = 0
    ship_cost = switch
      when weight <= 60 then 3.90
      when weight <= 100 then 4.37
      when weight <= 150 then 4.96
      when weight <= 200 then 5.55
      when weight <= 250 then 6.14
      when weight <= 300 then 6.72
      when weight <= 350 then 7.31
      when weight <= 400 then 7.90
      when weight <= 450 then 8.49
      when weight <= 500 then 9.08
      when weight <= 550 then 9.66
      when weight <= 600 then 10.25
      when weight <= 650 then 10.84
      when weight <= 700 then 11.43
      when weight <= 750 then 12.02
      when weight <= 800 then 12.61
      when weight <= 850 then 13.19
      when weight <= 900 then 13.78
      when weight <= 950 then 14.37
      when weight <= 1000 then 14.96
      else 20

    $('#product_shipping_price').val((ship_cost * 0.2).toFixed(2))
    product_cost = Number($('#product_cost').val())
    $('#product_price').val(product_cost + (ship_cost * 0.8).toFixed(2))
    return

  $('#product_weight,#product_cost').on 'change', calculatePrices


  $('#images-preview').slick
    dots: true
    infinite: false
    speed: 300
    slidesToShow: 1
    slidesToScroll: 1
    centerMode: true
    centerPadding: '60px'
    variableWidth: true

  $('#product_images').on 'change', ->
    if typeof FileReader != 'undefined'
      dvPreview = $('#dvPreview')
      dvPreview.html ''
      regex = /^([a-zA-Z0-9\s_\\.\-:])+(.jpg|.jpeg|.gif|.png|.bmp)$/
      $($(this)[0].files).each ->
        file = $(this)
        if regex.test(file[0].name.toLowerCase())
          reader = new FileReader

          reader.onload = (e) ->
            img_container = $("<li class='img-container'><img src= '" + e.target.result + "'/></li>")
            dvPreview.append img_container
            return

          reader.readAsDataURL file[0]
        else
          alert file[0].name + ' is not a valid image file.'
          dvPreview.html ''
          return false
        return
    else
      alert 'This browser does not support HTML5 FileReader.'
    return

  return
