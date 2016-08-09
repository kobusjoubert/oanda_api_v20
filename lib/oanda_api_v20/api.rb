module OandaApiV20
  class Api
    include Accounts
    include Orders
    include Trades
    include Positions
    include Transactions
    include Pricing

    attr_accessor :http_verb, :base_uri, :headers, :account_id, :last_transaction_id

    def initialize(options = {})
      options.each do |key, value|
        self.send("#{key}=", value) if self.respond_to?("#{key}=")
      end
    end
  end
end
