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
