require 'redis'
require 'json'

HOST = ENV['REDIS_HOST']
PORT = ENV['REDIS_PORT']
PASSWORD = ENV['REDIS_PASSWORD']

class RedisDb
  class << self
    def client
      Redis.new(url: "rediss://:#{PASSWORD}@#{HOST}:#{PORT}")
    end
  end
end