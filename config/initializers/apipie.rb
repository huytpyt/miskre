Apipie.configure do |config|
  config.app_name                = "MISKRE"
  config.api_base_url            = "/api/v1"
  config.doc_base_url            = "/docs"
  # where is your API defined?
  config.translate = false
  config.default_locale = nil
  config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "api", "v1", "**","*.rb")
end
