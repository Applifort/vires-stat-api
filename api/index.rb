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
      processed_count = Persister.digging(transactions, meta, client)
      client.hmset('state', 'action', nil, 'state', 'idle')
    when 'initial'
      client.hmset('state', 'action', 'initial', 'state', 'processing')
      transactions = Parser.get_vires_transactions
      processed_count = Persister.initial(transactions, meta, client)
      client.hmset('state', 'action', nil, 'state', 'idle')
    when 'continue'
      client.hmset('state', 'action', 'continue', 'state', 'processing')
      transactions = Parser.get_vires_transactions(meta['secondary_last_transaction_id'])
      processed_count = Persister.continue(transactions, meta, client)
      client.hmset('state', 'action', nil, 'state', 'idle')
    when 'latest'
      client.hmset('state', 'action', 'latest', 'state', 'processing')
      transactions = Parser.get_vires_transactions
      processed_count = Persister.latest(transactions, meta, client)
      client.hmset('state', 'action', nil, 'state', 'idle')
    end

    res.status = 200
    res['Content-Type'] = 'text/text; charset=utf-8'
    res.body = "Suceefully processed #{processed_count} transacttions\/n#{action}"
  end

  if state['state'] == 'processing'
    res.status = 200
    res['Content-Type'] = 'text/text; charset=utf-8'
    res.body = "Aborted"
  end
end
