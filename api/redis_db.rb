require 'redis'
require 'json'

HOST = ENV['REDIS_HOST']
PORT = ENV['REDIS_PORT']
PASSWORD = ENV['REDIS_PASSWORD']

class RedisDb
  attr_accessor :client

  def initialize
    @client = Redis.new(url: "rediss://:#{PASSWORD}@#{HOST}:#{PORT}")
  end

  def set(key, value)
    client.set(key, value.to_json)
  end

  def get(key)
    value = client.get(key)
    JSON.parse(value)
  end
end