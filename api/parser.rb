require 'net/http'
require 'uri'
require 'json'

URL = 'https://nodes.wavesnodes.com/transactions/address/3PAZv9tgK1PX7dKR7b4kchq5qdpUS3G5sYT'
LIMIT = 10

class Parser
  def parse_last_transactions
    uri = URI("#{URL}/limit/#{LIMIT}")
    res = Net::HTTP.get_response(uri)

    return unless if res.is_a?(Net::HTTPSuccess)

    raw_data = res.body
    JSON.parse(raw_data).first
  end
end
