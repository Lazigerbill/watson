uri = URI.parse(Figaro.env.REDISTOGO_URL)
REDIS = Redis.new(:url => uri)