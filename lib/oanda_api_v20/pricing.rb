# @see http://developer.oanda.com/rest-live-v20/pricing-ep/
module OandaApiV20
  module Pricing
    # GET /v3/accounts/:account_id/pricing
    def pricing(options)
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/pricing", headers: headers, query: options)
    end
  end
end
