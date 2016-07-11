# Sidekiq.configure_server do |config|
#   config.redis = { url: 'redis://redis.localhost:6379' }
# end

Sidekiq.configure_client do |config|
  config.redis = { url: Figaro.env.REDISTOGO_URL }
end