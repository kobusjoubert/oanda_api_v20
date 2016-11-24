# @see http://developer.oanda.com/rest-live-v20/account-ep/
module OandaApiV20
  module Accounts
    # GET /v3/accounts/:account_id
    def account(id)
      Client.send(http_verb, "#{base_uri}/accounts/#{id}", headers: headers)
    end

    # GET /v3/accounts
    def accounts
      Client.send(http_verb, "#{base_uri}/accounts", headers: headers)
    end

    # GET /v3/accounts/:account_id/summary
    def summary
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/summary", headers: headers)
    end

    # GET /v3/accounts/:account_id/instruments
    def instruments(instruments = nil)
      arguments = { headers: headers }
      arguments.merge!(query: { instruments: instruments }) if instruments
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/instruments", arguments)
    end

    # GET /v3/accounts/:account_id/changes
    def changes
      options = { 'sinceTransactionID' => last_transaction_id }
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/changes", headers: headers, query: options)
    end

    # PATCH /v3/accounts/:account_id/configuration
    def configuration(options = {})
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/configuration", headers: headers, body: options.to_json)
    end
  end
end
