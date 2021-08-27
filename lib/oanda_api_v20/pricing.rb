# @see http://developer.oanda.com/rest-live-v20/pricing-ep/
module OandaApiV20
  module Pricing
    # GET /v3/accounts/:account_id/pricing
    def pricing(options)
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/pricing", headers: headers, query: options)
    end

    # GET /v3/accounts/:account_id/pricing/stream
    def pricing_stream(options, &block)
      buffer = String.new

      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/pricing/stream", headers: headers, query: options, stream_body: true) do |fragment|
        if !fragment.empty?
          buffer << fragment
          parse(buffer, fragment, &block) if fragment.match(/\n\Z/)
        end
      end
    end
  end
end
