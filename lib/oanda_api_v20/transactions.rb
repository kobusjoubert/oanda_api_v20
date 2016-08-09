# @see http://developer.oanda.com/rest-live-v20/transactions-ep/
module OandaApiV20
  module Transactions
    # GET /v3/accounts/:account_id/transactions/:transaction_id
    def transaction(id)
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/transactions/#{id}", headers: headers)
    end

    # GET /v3/accounts/:account_id/transactions
    def transactions(options = {})
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/transactions", headers: headers, query: options)
    end

    # GET /v3/accounts/:account_id/transactions/idrange
    def transactions_id_range(options)
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/transactions/idrange", headers: headers, query: options)
    end

    # GET /v3/accounts/:account_id/transactions/sinceid
    def transactions_since_id(options)
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/transactions/sinceid", headers: headers, query: options)
    end
  end
end
