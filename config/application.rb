require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ShopCenter
  class Application < Rails::Application
    config.action_dispatch.default_headers['P3P'] = 'CP="Not used"'
    config.action_dispatch.default_headers.delete('X-Frame-Options')
    config.active_job.queue_adapter = :sidekiq
    Sidekiq::Extensions.enable_delay!
    config.middleware.use Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: [:get, :post, :put, :patch, :delete, :options]
      end
    end
  end
end
