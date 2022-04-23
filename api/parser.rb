require 'net/http'
require 'uri'
require 'json'

BASE_URL = 'https://nodes.wavesnodes.com'
VIRES_ADDRESS = '3PAZv9tgK1PX7dKR7b4kchq5qdpUS3G5sYT'
LIMIT = 100

class Parser
  class << self
    def get_vires_transactions(id = nil, limit = LIMIT)
      url = id.nil? ? vires_transactions_url(limit) : vires_transactions_with_pagination(id, limit)
      res = Net::HTTP.get_response(URI(url))

      raise 'Failed transactions requiest' unless res.is_a?(Net::HTTPSuccess)

      raw_data = res.body
      JSON.parse(raw_data).first
    end

    private

    def vires_transactions_with_pagination(id, limit)
      "#{vires_transactions_url(limit)}?after=#{id}"
    end

    def vires_transactions_url(limit)
      "#{transactions_url}/address/#{VIRES_ADDRESS}/limit/#{limit}"
    end

    def transactions_url
      "#{BASE_URL}/transactions"
    end
  end
end
