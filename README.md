# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Use sidekiq
  required install redis
  $ redis-server
  $ bundle exec sidekiq
* Deployment instructions

* Elasticsearch:
  Install and start elasticsearch belongs to your operator system

* Docker 
  - Build:
    $ docker-compose -f docker-compose.production.yml build --no-cache 
  - Run migration:
    $ docker-compose -f docker-compose.production.yml run app rake db:migrate
  - Up:
    $ docker-compose -f docker-compose.production.yml up -d 
  - Stop
    $ docker-compose -f docker-compose.production.yml down
    
* ...
