# @see http://developer.oanda.com/rest-live-v20/positions-ep/
module OandaApiV20
  module Positions
    # GET /v3/accounts/:account_id/positions/:instrument
    # PUT /v3/accounts/:account_id/positions/:instrument/close
    def position(*args)
      instrument = args.shift
      options = args.shift unless args.nil? || args.empty?

      url = "#{base_uri}/accounts/#{account_id}/positions/#{instrument}"
      url = position_url_for_put(url, options) if http_verb == :put

      options ? Client.send(http_verb, url, headers: headers, body: options.to_json) : Client.send(http_verb, url, headers: headers)
    end

    # GET /v3/accounts/:account_id/positions
    def positions
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/positions", headers: headers)
    end

    # GET /v3/accounts/:account_id/openPositions
    def open_positions
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/openPositions", headers: headers)
    end

    private

    def position_url_for_put(url, options = nil)
      return "#{url}/close" unless options
      return "#{url}/close" if options['longUnits'] || options['longClientExtensions'] || options['shortUnits'] || options['shortClientExtensions']
      return url
    end
  end
end
