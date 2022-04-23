class Persister
  class << self
    def discard_state(client)
      client.hmset('meta', 'main_head_transaction_id', nil)
      client.hmset('meta', 'main_last_transaction_id', nil)
      client.hmset('meta', 'secondary_head_transaction_id', nil)
      client.hmset('meta', 'secondary_last_transaction_id', nil)
    end

    def initial(transactions, _meta, client)
      processed_count = 0
      processed_transactions = []
      main_head_transaction_id = nil
      main_last_transaction_id = nil

      transactions.each_with_index do |transaction, index|
        transaction_id = transaction['id']
        main_head_transaction_id = transaction_id if index.zero?
        main_last_transaction_id = transaction_id

        timestamp = transaction['timestamp']
        processed_transactions << [timestamp, transaction.to_json]

        processed_count += 1
      end

      client.multi do |multi|
        multi.hmset('meta', 'main_head_transaction_id', main_head_transaction_id)
        multi.hmset('meta', 'main_last_transaction_id', main_last_transaction_id)
        multi.zadd('transactions', processed_transactions.flatten)
      end

      processed_count
    end

    def continue(transactions, meta, client)
      main_head_transaction_id = meta['main_head_transaction_id']
      secondary_head_transaction_id = meta['secondary_head_transaction_id']
      secondary_last_transaction_id = nil

      processed_count = 0
      processed_transactions = []

      transactions.each do |transaction|
        transaction_id = transaction['id']
        timestamp = transaction['timestamp']

        if main_head_transaction_id == transaction_id
          main_head_transaction_id = secondary_head_transaction_id
          secondary_last_transaction_id = nil
          secondary_head_transaction_id = nil
          break
        end

        processed_transactions << [timestamp, transaction.to_json]
        secondary_last_transaction_id = transaction_id
        processed_count += 1
      end

      client.multi do |multi|
        multi.hmset('meta', 'main_head_transaction_id', main_head_transaction_id)
        multi.hmset('meta', 'secondary_head_transaction_id', secondary_head_transaction_id)
        multi.hmset('meta', 'secondary_last_transaction_id', secondary_last_transaction_id)
        multi.zadd('transactions', processed_transactions.flatten) unless processed_transactions.empty?
      end

      processed_count
    end

    def latest(transactions, meta, client)
      main_head_transaction_id = meta['main_head_transaction_id']
      secondary_head_transaction_id = nil
      secondary_last_transaction_id = nil

      processed_count = 0
      processed_transactions = []

      transactions.each_with_index do |transaction, index|
        transaction_id = transaction['id']
        timestamp = transaction['timestamp']

        if main_head_transaction_id == transaction_id
          main_head_transaction_id = index.zero? ? transaction_id : secondary_head_transaction_id
          secondary_head_transaction_id = nil
          secondary_last_transaction_id = nil
          break
        end

        secondary_head_transaction_id = transaction_id if index.zero?
        secondary_last_transaction_id = transaction_id
        processed_transactions << [timestamp, transaction.to_json]

        processed_count += 1
      end

      client.multi do |multi|
        multi.hmset('meta', 'secondary_head_transaction_id', secondary_head_transaction_id)
        multi.hmset('meta', 'secondary_last_transaction_id', secondary_last_transaction_id)
        multi.hmset('meta', 'main_head_transaction_id', main_head_transaction_id)
        multi.zadd('transactions', processed_transactions.flatten) unless processed_transactions.empty?
      end

      processed_count
    end

    def digging(transactions, meta, client)
      main_last_transaction_id = meta['main_last_transaction_id']
      processed_count = 0
      processed_transactions = []

      transactions.each_with_index do |transaction, index|
        transaction_id = transaction['id']
        timestamp = transaction['timestamp']

        processed_transactions << [timestamp, transaction.to_json]
        main_last_transaction_id = transaction_id

        processed_count += 1
      end

      client.multi do |multi|
        multi.hmset('meta', 'main_last_transaction_id', main_last_transaction_id)
        multi.zadd('transactions', processed_transactions.flatten) unless processed_transactions.empty?
      end

      processed_count
    end
  end
end