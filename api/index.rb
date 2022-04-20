require './api/redis_db'
require './api/parser'

Handler = Proc.new do |req, res|
  client = RedisDb.new

  client.set('processed_entities', 0)

  transactions = Parser.parse_last_transactions
  transactions.each do |transaction|
    transaction_id = transaction['id']
    invokes = transaction.dig('stateChanges', 'invokes')

    client.multi do |multi|
      multi.set('last_parsed_transaction_id', transaction_id)
      multi.incr("processed_entities")
      if kind_of?(Array)
        invoke = invokes.find {|inv| ['depositFor', 'withdrawFor'].include? inv.dig('call', 'function')}
        if !invoke.nil?
          multi.hset('transactions', transaction_id, invoke.dig('call', 'function').to_json)
        end
      end
    end
  end

  res.status = 200
  res['Content-Type'] = 'text/text; charset=utf-8'
  res.body = "OK"
end
