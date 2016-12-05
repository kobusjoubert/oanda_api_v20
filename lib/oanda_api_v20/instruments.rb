# @see http://developer.oanda.com/rest-live-v20/instrument-ep/
module OandaApiV20
  module Instruments
    attr_accessor :instrument

    # GET /v3/instruments/:instrument/candles
    def candles(options = {})
      Client.send(http_verb, "#{base_uri}/instruments/#{instrument}/candles", headers: headers, query: options)
    end
  end
end
