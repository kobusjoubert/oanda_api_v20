# @see http://developer.oanda.com/rest-live-v20/pricing-ep/
module OandaApiV20
  module Pricing
    # GET /v3/accounts/:account_id/pricing
    def pricing(options)
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/pricing", headers: headers, query: options)
    end

    # GET /v3/accounts/:account_id/pricing/stream
    def pricing_stream(options, &block)
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/pricing/stream", headers: headers, query: options, stream_body: true) do |fragment|
        next if fragment.empty?
        parsed_json = JSON.parse(fragment)
        next unless parsed_json['type'] == 'PRICE'
        yield parsed_json
      rescue => e
        puts "Malformed JSON: #{fragment} #{e.message}"
      end
    end
  end
end
