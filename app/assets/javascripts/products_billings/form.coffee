$(document).ready ->
  $('#product_product_ids').chosen
    allow_single_deselect: true
    placeholder_text_multiple: "Select some products"
    no_results_text: 'No results matched'

  $('#product_is_bundle').click ->
    if $('#bundle_products').css('visibility') == 'hidden'
      $('#bundle_products').css 'visibility', 'visible'
    else
      $('#bundle_products').css 'visibility', 'hidden'
    return
  
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