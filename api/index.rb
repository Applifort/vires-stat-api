require './api/redis_db'
require './api/parser'
require './api/persister'
require './api/helper'

Handler = Proc.new do |req, res|
  client = RedisDb.client

  meta = client.hgetall('meta')
  state = client.hgetall('state')

  begin
    if state['state'] == 'idle'
      action = Helper.get_action(meta, req.query['action'])
      client.hmset('state', 'action', action, 'state', 'processing', 'error', '')

      case action
      when 'dig'
        transactions = Parser.get_vires_transactions(meta['main_last_transaction_id'])
        processed_count, time = Persister.digging(transactions, meta, client)
      when 'initial'
        transactions = Parser.get_vires_transactions
        processed_count, time = Persister.initial(transactions, meta, client)
      when 'continue'
        transactions = Parser.get_vires_transactions(meta['secondary_last_transaction_id'])
        processed_count, time = Persister.continue(transactions, meta, client)
      when 'latest'
        transactions = Parser.get_vires_transactions
        processed_count, time = Persister.latest(transactions, meta, client)
      end
      client.hmset('state', 'action', nil, 'state', 'idle')

      res.status = 200
      res['Content-Type'] = 'text/text; charset=utf-8'
      res.body = "Suceefully processed #{processed_count} transactions. Last transaction processed date #{time}"
    end

    if state['state'] == 'processing'
      res.status = 200
      res['Content-Type'] = 'text/text; charset=utf-8'
      res.body = "Aborted. Processing!"
    end

    if state['state'] = 'error'
      res.status = 500
      res['Content-Type'] = 'text/text; charset=utf-8'
      res.body = "State error: #{state['error_message']}"
    end
  rescue => error
    res.status = 500
    res['Content-Type'] = 'text/text; charset=utf-8'
    res.body = "Error: #{error.message}"
    client.hmset('state', 'action', nil, 'state', 'error', 'error_message', "#{error.class} - #{error.message}")
  end
end
