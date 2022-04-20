require './api/redis_db'

Handler = Proc.new do |req, res|

  client = RedisDb.new
  client.set('first', 'value')

  res.status = 200
  res['Content-Type'] = 'text/text; charset=utf-8'
  res.body = "OK"
end
