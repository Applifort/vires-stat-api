require './api/redis_db'
require './api/parser'
require './api/persister'
require './api/helper'

Handler = Proc.new do |req, res|
  client = RedisDb.client

  state = client.hgetall('state')
  action = Helper.get_state(state, req['action'])

  client.set('req', req)
  client.set('test_state', state)

  # case state
  # when 'dig'
  #   transactions = Parser.get_vires_transactions(state['main_last_transaction_id'])
  #   Persister.digging(transactions, state, client)
  # when 'initial'
  #   transactions = Parser.get_vires_transactions
  #   Persister.initial(transactions, state, client)
  # when 'continue'
  #   transactions = Parser.get_vires_transactions(state['secondary_last_transaction_id'])
  #   Persister.continue(transactions, state, client)
  # when 'latest'
  #   transactions = Parser.get_vires_transactions
  #   Persister.latest(transactions, state, client)
  # end

  res.status = 200
  res['Content-Type'] = 'text/text; charset=utf-8'
  res.body = "OK"
end
