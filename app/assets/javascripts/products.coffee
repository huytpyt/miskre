# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

Dropzone.options.productForm =
  paramName: 'images'
  autoProcessQueue: false
  uploadMultiple: true
  parallelUploads: 100
  maxFiles: 100
  addRemoveLinks: true
  previewsContainer: '.dropzone-previews'

  init: ->
    myDropzone = this
    # First change the button to actually tell Dropzone to process the queue.
    @element.querySelector('#submit-product').addEventListener 'click', (e) ->
      # Make sure that the form isn't actually being sent.
      e.preventDefault()
      e.stopPropagation()
      myDropzone.processQueue()
      return
    # Listen to the sendingmultiple event. In this case, it's the sendingmultiple event instead
    # of the sending event because uploadMultiple is set to true.
    @on 'sendingmultiple', ->
      # Gets triggered when the form is actually being sent.
      # Hide the success button or the complete form.
      return
    @on 'successmultiple', (files, response) ->
      # Gets triggered when the files have successfully been sent.
      # Redirect user or notify of success.
      window.location.href = '/products/' + response.id
      return
    @on 'errormultiple', (files, response) ->
      # Gets triggered when there was an error sending the files.
      # Maybe show form again, and notify user of error


$(document).ready ->
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

  return


