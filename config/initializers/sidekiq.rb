# This configures Sidekiq to use ENV variable, PROD connects to Redis-to-go
# uri = URI.parse(Figaro.env.redis_uri)

Sidekiq.configure_server do |config|
  config.redis = { :url => Figaro.env.REDISTOGO_URL }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => Figaro.env.REDISTOGO_URL }
end