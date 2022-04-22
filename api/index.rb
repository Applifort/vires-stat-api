require './api/redis_db'
require './api/parser'
require './api/persister'
require './api/helper'

Handler = Proc.new do |req, res|
  client = RedisDb.client

  state = client.hgetall('state')
  action = Helper.get_state(state, req['action'])

  case state
  when 'dig'
    transactions = Parser.get_vires_transactions(state['main_last_transaction_id'])
    Persister.persist_digging(transactions, state, client)
  when 'initial'
    transactions = Parser.get_vires_transactions
    Persister.persist_initial(transactions, state, client)
  when 'update'
    transactions = Parser.get_vires_transactions(state['secondary_last_transaction_id'])
    Persister.persist_update(transactions, state, client)
  when 'idle'
    transactions = Parser.get_vires_transactions
    Persister.persist_refresh(transactions, state, client)
  end

  res.status = 200
  res['Content-Type'] = 'text/text; charset=utf-8'
  res.body = "OK"
end
