# @see http://developer.oanda.com/rest-live-v20/orders-ep/
module OandaApiV20
  module Orders
    # POST /v3/accounts/:account_id/orders
    # GET  /v3/accounts/:account_id/orders/:order_id
    # PUT  /v3/accounts/:account_id/orders/:order_id
    # PUT  /v3/accounts/:account_id/orders/:order_id/clientExtensions
    # PUT  /v3/accounts/:account_id/orders/:order_id/cancel
    def order(*args)
      id_or_options = args.shift
      id_or_options.is_a?(Hash) ? options = id_or_options : id = id_or_options
      options = args.shift unless args.nil? || args.empty?

      url = id ? "#{base_uri}/accounts/#{account_id}/orders/#{id}" : "#{base_uri}/accounts/#{account_id}/orders"
      url = order_url_for_put(url, options) if http_verb == :put

      options ? Client.send(http_verb, url, headers: headers, body: options.to_json) : Client.send(http_verb, url, headers: headers)
    end

    # GET /v3/accounts/:account_id/orders
    def orders
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/orders", headers: headers)
    end

    # GET /v3/accounts/:account_id/pendingOrders
    def pending_orders
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/pendingOrders", headers: headers)
    end

    private

    def order_url_for_put(url, options = nil)
      return "#{url}/cancel" unless options
      return "#{url}/clientExtensions" if options['clientExtensions'] || options['tradeClientExtensions']
      return url if options['order']
      return url
    end
  end
end
