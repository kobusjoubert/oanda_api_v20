# @see http://developer.oanda.com/rest-live-v20/trades-ep/
module OandaApiV20
  module Trades
    # GET /v3/accounts/:account_id/trades/:trade_id
    # PUT /v3/accounts/:account_id/trades/:trade_id/orders
    # PUT /v3/accounts/:account_id/trades/:trade_id/clientExtensions
    # PUT /v3/accounts/:account_id/trades/:trade_id/close
    def trade(*args)
      id = args.shift
      options = args.shift unless args.nil? || args.empty?

      url = "#{base_uri}/accounts/#{account_id}/trades/#{id}"
      url = trade_url_for_put(url, options) if http_verb == :put

      options ? Client.send(http_verb, url, headers: headers, body: options.to_json) : Client.send(http_verb, url, headers: headers)
    end

    # GET /v3/accounts/:account_id/trades
    def trades(options)
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/trades", headers: headers, query: options)
    end

    # GET /v3/accounts/:account_id/openTrades
    def open_trades
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/openTrades", headers: headers)
    end

    private

    def trade_url_for_put(url, options = nil)
      return "#{url}/close" unless options
      return "#{url}/clientExtensions" if options['clientExtensions']
      return "#{url}/orders" if options['takeProfit'] || options['stopLoss'] || options['trailingStopLoss']
      return "#{url}/close" if options['units']
      return url
    end
  end
end
