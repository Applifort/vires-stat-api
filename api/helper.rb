class Helper
  class << self
    def get_state(state, action)
      main_head_transaction_id = state['main_head_transaction_id']
      main_last_transaction_id = state['main_last_transaction_id']
      secondary_head_transaction_id = state['secondary_head_transaction_id']
      secondary_last_transaction_id = state['secondary_last_transaction_id']

      return 'dig' if action == 'dig'
      return 'initial' if main_head_transaction_id.empty? && main_last_transaction_id.empty?
      return 'update' if secondary_head_transaction_id.empty? && secondary_last_transaction_id.empty?
      'idle'
    end
  end
end
