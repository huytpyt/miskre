# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(
  slick-carousel/slick/slick.css
  slick-carousel/slick/slick-theme.css
  slick-carousel/slick/slick.min.js
  ckeditor/*
  chosen-jquery
  shops
  reports
  products_billings/form
  orders/index
  shipping_rates
  options
  variants
  edit_variants

  login/welcome.css
  Detector.js
  three.min.js
  Tween.js
  globe.js
  welcome.js
  tracking_information.css
)
