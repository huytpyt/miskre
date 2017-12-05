source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.4'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'rack-cors', :require => 'rack/cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'annotate'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "pry-rails"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'shopify_app', '~> 7.3'
gem 'slim', '~> 3.0', '>= 3.0.8'
gem 'simple_form', '~> 3.5'
gem 'devise', '~> 4.3'
gem 'foundation-rails', '~> 6.4', '>= 6.4.1.2'
gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.2'
gem 'paperclip', '~> 5.1'
gem 'bower-rails', '~> 0.11.0'
gem 'rails_admin', '~> 1.2'
gem 'cancancan', '~> 1.13', '>= 1.13.1'
gem 'enumerize', '~> 2.1', '>= 2.1.2'
# Import CSV, XLS, XLSX
gem 'roo', '~> 2.7', '>= 2.7.1'
gem "iconv", "~> 1.0.3"
gem 'roo-xls', '~> 1.1'

gem 'countries', '~> 2.1', '>= 2.1.2'
gem 'ckeditor', '~> 4.2', '>= 4.2.4'
gem 'kaminari', '~> 1.0', '>= 1.0.1'
gem 'jquery-datatables-rails', '~> 3.4'
gem 'chosen-rails', '~> 1.5', '>= 1.5.2'
gem 'vuejs-rails', '~> 2.4', '>= 2.4.2'

group :development do
  gem 'capistrano', '~> 3.9'
  gem 'capistrano-rails', '~> 1.3'
  gem 'capistrano-rbenv', '~> 2.1', '>= 2.1.1'
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-rails-console', '~> 2.2'
  gem 'web-console', '>= 3.3.0'
  gem "better_errors"
  gem "binding_of_caller"
end

# For super search
# gem 'elasticsearch-rails', '~> 0.1.7'
# gem 'elasticsearch-model', '~> 0.1.7'
gem 'sidekiq'
gem 'sidekiq-scheduler'
# Environment variables
gem 'figaro', '~> 1.1', '>= 1.1.1'
gem 'stripe', '~> 3.3', '>= 3.3.1'
