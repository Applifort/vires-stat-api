require './api/redis_db'
require './api/parser'
require './api/persister'
require './api/helper'

Handler = Proc.new do |req, res|
  client = RedisDb.client

  meta = client.hgetall('meta')
  state = client.hgetall('state')

  unless state['state'] == 'processing'
    action = Helper.get_action(meta, req.query['action'])

    case action
    when 'dig'
      client.hmset('state', 'action', 'dig', 'state', 'processing')
      transactions = Parser.get_vires_transactions(meta['main_last_transaction_id'])
      Persister.digging(transactions, meta, client)
      client.hmset('state', 'action', nil, 'state', 'idle')
    when 'initial'
      client.hmset('state', 'initial', 'dig', 'state', 'processing')
      transactions = Parser.get_vires_transactions
      Persister.initial(transactions, meta, client)
      client.hmset('state', 'action', nil, 'state', 'idle')
    when 'continue'
      client.hmset('state', 'initial', 'continue', 'state', 'processing')
      transactions = Parser.get_vires_transactions(meta['secondary_last_transaction_id'])
      Persister.continue(transactions, meta, client)
      client.hmset('state', 'action', nil, 'state', 'idle')
    when 'latest'
      client.hmset('state', 'latest', 'dig', 'state', 'processing')
      transactions = Parser.get_vires_transactions
      Persister.latest(transactions, meta, client)
      client.hmset('state', 'action', nil, 'state', 'idle')
    end

    res.status = 200
    res['Content-Type'] = 'text/text; charset=utf-8'
    res.body = "Suceefully processed \/n#{action}"
    return
  end

  res.status = 200
  res['Content-Type'] = 'text/text; charset=utf-8'
  res.body = "Aborted"
end
