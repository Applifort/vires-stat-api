class Helper
  class << self
    def get_action(meta, action)
      main_head_transaction_id = meta['main_head_transaction_id']
      main_last_transaction_id = meta['main_last_transaction_id']
      secondary_head_transaction_id = meta['secondary_head_transaction_id']
      secondary_last_transaction_id = meta['secondary_last_transaction_id']

      return 'dig' if action == 'dig'
      return 'initial' if main_head_transaction_id.empty? && main_last_transaction_id.empty?
      return 'latest' if secondary_head_transaction_id.empty? && secondary_last_transaction_id.empty?
      'continue'
    end
  end
end
