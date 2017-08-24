$( document ).ready(function() {
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
});
