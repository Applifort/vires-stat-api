class Persister
  class << self
    def persist_initial(transactions, state)
      main_head_transaction_id = state['main_head_transaction_id']
      main_last_transaction_id = state['main_last_transaction_id']
      secondary_head_transaction_id = state['secondary_head_transaction_id']
      secondary_last_transaction_id = state['secondary_last_transaction_id']
      
      transactions.each_with_index do |transaction, index|
        timestamp = transaction['timestamp']
        date = parse_date(timestamp)

        client.multi do |multi|
          multi.hset('state', 'main_head_transaction_id', transaction_id) if index.zero?
          multi.hset('state', 'main_last_transaction_id', transaction_id)
          multi.zadd('transactions', timestamp, transaction.to_json)
        end
      end

    end

    private

    def grap(transactions)
      filtered_transactions = []

      transactions.each_with_index do |transaction, index|
        transaction_id = transaction['id']
        invokes = allocate(transaction)
        invoke = find_deposits_or_withdrowals_invoke(invokes)

        client.multi do |multi|
          multi.set('main_head_transaction_id', transaction_id) if index.zero?
          multi.set('main_last_transaction_id', transaction_id)
          if !invoke.nil?
            timestamp = transaction['timestamp']
            date =  parse_date(timestamp)
            filtered_transactions << transaction
          end
        end
      end
      filtered_transactions
    end

    def allocate(invoke)
      invokes = invoke.dig('stateChanges', 'invokes')
      return [invoke] if invokes.empty?

      return [invoke, invokes.map { |inv| allocate(inv) }].flatten
    end

    def parse_date(timestamp)
      Time.at(timestamp.to_i / 1000).strftime('%F')
    end

    def find_deposits_or_withdrowals_invoke(invokes)
      invokes.find {|inv| ['depositFor', 'withdrawFor'].include? inv.dig('call', 'function')}
    end
  end
end