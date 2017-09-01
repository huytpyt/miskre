server '54.183.251.29', roles: [:web, :app, :db], primary: true

set :ssh_options, {
  forward_agent: true,
  user: fetch(:user),
  keys: %w(~/.ssh/miskre.pem)
}

set :stage, :production
