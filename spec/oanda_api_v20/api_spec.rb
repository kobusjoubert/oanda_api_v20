require 'spec_helper'

describe OandaApiV20::Api do
  describe '#initialize' do
    let!(:client) { OandaApiV20::Client.new(access_token: 'my_access_token') }

    it 'sets the client attribute when supplied' do
      api = OandaApiV20::Api.new(client: client)
      expect(api.client).to eq(client)
    end

    it 'raises an OandaApiV20::ApiError exception when no client object was supplied' do
      expect{ OandaApiV20::Api.new }.to raise_error(OandaApiV20::ApiError)
    end

    it 'sets the base_uri attribute when supplied' do
      url = 'https://api-fxpractice.oanda.com/v3'
      api = OandaApiV20::Api.new(client: client, base_uri: url)
      expect(api.base_uri).to eq(url)
    end

    it 'sets the default base_uri attribute when not supplied' do
      api = OandaApiV20::Api.new(client: client)
      expect(api.base_uri).to eq('https://api-fxtrade.oanda.com/v3')
    end

    it 'sets the headers attribute when supplied' do
      headers = { 'Content-Type' => 'application/json', 'Connection' => 'keep-alive', 'Keep-Alive' => '30' }
      api = OandaApiV20::Api.new(client: client, headers: headers)
      expect(api.headers).to eq(headers)
    end

    it 'sets the default headers attribute when not supplied' do
      api = OandaApiV20::Api.new(client: client)
      expect(api.headers).to eq({ 'Authorization' => 'Bearer my_access_token', 'X-Accept-Datetime-Format' => 'RFC3339', 'Content-Type' => 'application/json' })
    end

    it 'sets the account_id attribute when supplied' do
      account_id = '100-100-100'
      api = OandaApiV20::Api.new(client: client, account_id: account_id)
      expect(api.account_id).to eq(account_id)
    end

    it 'sets the instrument variable when supplied' do
      instrument = 'EUR_USD'
      api = OandaApiV20::Api.new(client: client, instrument: instrument)
      expect(api.instance_variable_get(:@instrument)).to eq(instrument)
    end

    it 'sets the last_action when supplied' do
      api = OandaApiV20::Api.new(client: client, last_action: 'accounts')
      expect(api.last_action).to eq('accounts')
    end

    it 'sets the last_arguments when supplied' do
      api = OandaApiV20::Api.new(client: client, last_action: 'account', last_arguments: ['100-100-100'])
      expect(api.last_action).to eq('account')
      expect(api.last_arguments).to eq(['100-100-100'])
    end
  end

  describe '#method_missing' do
    describe 'constructs the correct API URL under' do
      let!(:client)        { OandaApiV20::Client.new(access_token: 'my_access_token', base_uri: 'https://api-fxtrade.oanda.com/v3', headers: {}) }
      let!(:stream_client) { OandaApiV20::Client.new(access_token: 'my_access_token', base_uri: 'https://api-fxtrade.oanda.com/v3', headers: {}, stream: true) }
      let!(:api)           { OandaApiV20::Api.new(client: client, account_id: '100-100-100') }
      let!(:stream_api)    { OandaApiV20::Api.new(client: stream_client, account_id: '100-100-100') }

      before(:each) do
        stub_request(:get, /https:\/\/api-fxtrade\.oanda\.com\/v3.*/)
      end

      context 'accounts for' do
        it 'retrieving an account' do
          api.account('100-100-100').show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100')).to have_been_made.once
        end

        it 'retrieving all accounts' do
          api.accounts.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts')).to have_been_made.once
        end

        it 'retrieving a summary' do
          api.summary.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/summary')).to have_been_made.once
        end

        it 'retrieving all instruments' do
          api.instruments.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/instruments')).to have_been_made.once
        end

        it 'retrieving an instrument' do
          api.instruments('EUR_USD').show
          options = { 'instruments' => 'EUR_USD' }
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/instruments').with(query: options)).to have_been_made.once
        end

        it 'retrieving no changes' do
          options = {}
          api.changes(options).show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/changes').with(query: { 'sinceTransactionID' => '' })).to have_been_made.once
        end

        it 'retrieving all changes since a transaction ID' do
          options = { 'sinceTransactionID' => '1' }
          api.changes(options).show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/changes').with(query: options)).to have_been_made.once
        end

        it 'updating a configuration' do
          options = { 'alias' => 'Timmy!' }
          request = stub_request(:patch, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/configuration').with(body: options)
          api.configuration(options).update
          expect(request).to have_been_requested.once
        end
      end

      context 'instruments for' do
        let!(:api) { OandaApiV20::Api.new(client: client, account_id: '100-100-100', instrument: 'EUR_USD') }

        it 'retrieving candlestick data' do
          options = { 'count' => '10' }
          api.candles(options).show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/instruments/EUR_USD/candles').with(query: options)).to have_been_made.once
        end
      end

      context 'orders for' do
        it 'retrieving an order' do
          api.order('1').show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders/1')).to have_been_made.once
        end

        it 'creating an order' do
          options = {
            'order' => {
              'units' => '100',
              'instrument' => 'EUR_CAD',
              'timeInForce' => 'FOK',
              'type' => 'MARKET',
              'positionFill' => 'DEFAULT'
            }
          }
          request = stub_request(:post, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders').with(body: options)
          api.order(options).create
          expect(request).to have_been_requested.once
        end

        it 'updating an order' do
          options = {
            'order' => {
              'timeInForce' => 'GTC',
              'price' => '1.7000',
              'type' => 'TAKE_PROFIT',
              'tradeID' => '1'
            }
          }
          request = stub_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders/1').with(body: options)
          api.order('1', options).update
          expect(request).to have_been_requested.once
        end

        it 'updating an order client extensions' do
          options = {
            'clientExtensions' => {
              'comment' => 'New comment for my limit order'
            }
          }
          request = stub_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders/1/clientExtensions').with(body: options)
          api.order('1', options).update
          expect(request).to have_been_requested.once
        end

        it 'cancelling an order' do
          request = stub_request(:put,'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders/1/cancel')
          api.order('1').cancel
          expect(request).to have_been_requested.once
        end

        it 'retrieving all orders' do
          api.orders.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders')).to have_been_made.once
        end

        it 'retrieving all orders' do
          options = { 'instrument' => 'USD_CAD' }
          api.orders(options).show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders').with(query: options)).to have_been_made.once
        end

        it 'retrieving all pending orders' do
          api.pending_orders.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/pendingOrders')).to have_been_made.once
        end
      end

      context 'trades for' do
        it 'retrieving a trade' do
          api.trade('1').show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades/1')).to have_been_made.once
        end

        it 'updating a trade' do
          options = {
            'takeProfit' => {
              'timeInForce' => 'GTC',
              'price' => '0.5'
            },
            'stopLoss' => {
              'timeInForce' => 'GTC',
              'price' => '2.5'
            }
          }
          request = stub_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades/1/orders').with(body: options)
          api.trade('1', options).update
          expect(request).to have_been_requested.once
        end

        it 'updating a trade client extensions' do
          options = {
            'clientExtensions' => {
              'comment' => 'This is a USD/CAD trade',
              'tag' => 'trade tag',
              'id' => 'my_usd_cad_trade'
            }
          }
          request = stub_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades/1/clientExtensions').with(body: options)
          api.trade('1', options).update
          expect(request).to have_been_requested.once
        end

        it 'closing a trade' do
          request = stub_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades/1/close')
          api.trade('1').close
          expect(request).to have_been_requested.once
        end

        it 'closing a trade partially' do
          options = { 'units' => '10' }
          request = stub_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades/1/close')
          api.trade('1', options).close
          expect(request).to have_been_requested.once
        end

        it 'retrieving all trades' do
          options = { 'instrument' => 'USD_CAD' }
          api.trades(options).show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades').with(query: options)).to have_been_made.once
        end

        it 'retrieving all open trades' do
          api.open_trades.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/openTrades')).to have_been_made.once
        end
      end

      context 'positions for' do
        it 'retrieving a position' do
          api.position('EUR_USD').show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/positions/EUR_USD')).to have_been_made.once
        end

        it 'retrieving all positions' do
          api.positions.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/positions')).to have_been_made.once
        end

        it 'retrieving all open positions' do
          api.open_positions.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/openPositions')).to have_been_made.once
        end

        it 'closing a position' do
          options = { 'longUnits' => 'ALL' }
          request = stub_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/positions/EUR_CAD/close').with(body: options)
          api.position('EUR_CAD', options).close
          expect(request).to have_been_requested.once
        end

        it 'closing a position partially' do
          options = { 'longUnits' => '99' }
          request = stub_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/positions/EUR_CAD/close').with(body: options)
          api.position('EUR_CAD', options).close
          expect(request).to have_been_requested.once
        end
      end

      context 'transactions for' do
        it 'retrieving a transaction' do
          api.transaction('1').show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/transactions/1')).to have_been_made.once
        end

        it 'retrieving all transactions' do
          api.transactions.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/transactions')).to have_been_made.once
        end

        it 'retrieving all transactions in date range' do
          options = {
            'from' => '2016-08-01T02:00:00Z',
            'to' => '2016-08-15T02:00:00Z'
          }
          api.transactions(options).show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/transactions').with(query: options)).to have_been_made.once
        end

        it 'retrieving all transactions in an ID range' do
          options = {
            'from' => '6409',
            'to' => '6412'
          }
          api.transactions_id_range(options).show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/transactions/idrange').with(query: options)).to have_been_made.once
        end

        it 'retrieving all transactions since an ID' do
          options = {
            'id' => '6411'
          }
          api.transactions_since_id(options).show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/transactions/sinceid').with(query: options)).to have_been_made.once
        end

        it 'retrieving all transactions stream' do
          body = <<~EOF
{"id":"6","accountID":"100-100-100","userID":12345678,"batchID":"4","requestID":"11111111111111111","time":"2021-08-20T11:56:39.037505525Z","type":"TAKE_PROFIT_ORDER","tradeID":"5","timeInForce":"GTC","triggerCondition":"DEFAULT","price":"0.71388","reason":"ON_FILL"}\n{"id":"7","accountID":"100-100-100","userID":12345678,"batchID":"4","requestID":"11111111111111112","time":"2021-08-20T11:56:39.037505525Z","type":"STOP_LOSS_ORDER","tradeID":"5","timeInForce":"GTC","triggerCondition":"DEFAULT","triggerMode":"TOP_OF_BOOK","price":"0.71258","distance":"0.00030","reason":"ON_FILL"}\n\r\n
EOF

          headers = {
            'Transfer-Encoding' => 'chunked',
            'Content-Type' => 'application/octet-stream'
          }

          stub_request(:get, 'https://stream-fxtrade.oanda.com/v3/accounts/100-100-100/transactions/stream').to_return(status: 200, body: body, headers: headers)

          messages = []

          stream_api.transactions_stream.show do |message|
            messages << message
          end

          expect(a_request(:get, 'https://stream-fxtrade.oanda.com/v3/accounts/100-100-100/transactions/stream')).to have_been_made.once
          expect(messages.count).to eq(2)
        end
      end

      context 'pricing for' do
        it 'retrieving all pricing' do
          options = {
            'instruments' => 'EUR_USD,USD_CAD'
          }
          api.pricing(options).show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/pricing').with(query: options)).to have_been_made.once
        end

        it 'retrieving all pricing stream' do
          options = {
            'instruments' => 'EUR_USD,USD_CAD'
          }

          body = <<~EOF
{"type":"PRICE","time":"2019-01-31T18:16:38.818627106Z","bids":[{"price":"0.72711","liquidity":10000000}],"asks":[{"price":"0.72725","liquidity":10000000}],"closeoutBid":"0.72696","closeoutAsk":"0.72740","status":"tradeable","tradeable":true,"instrument":"USD_CAD"}\n{"type":"PRICE","time":"2019-01-31T18:16:48.270050596Z","bids":[{"price":"0.95533","liquidity":10000000}],"asks":[{"price":"0.95554","liquidity":10000000}],"closeoutBid":"0.95533","closeoutAsk":"0.95554","status":"tradeable","tradeable":true,"instrument":"EUR_USD"}\n\r\n
EOF

          headers = {
            'Transfer-Encoding' => 'chunked',
            'Content-Type' => 'application/octet-stream'
          }

          stub_request(:get, 'https://stream-fxtrade.oanda.com/v3/accounts/100-100-100/pricing/stream?instruments=EUR_USD,USD_CAD').to_return(status: 200, body: body, headers: headers)

          messages = []

          stream_api.pricing_stream(options).show do |message|
            messages << message
          end

          expect(a_request(:get, 'https://stream-fxtrade.oanda.com/v3/accounts/100-100-100/pricing/stream').with(query: options)).to have_been_made.once
          expect(messages.count).to eq(2)
        end
      end
    end

    describe 'network' do
      let!(:client) { OandaApiV20::Client.new(access_token: 'my_access_token', base_uri: 'https://api-fxtrade.oanda.com/v3', headers: {}) }
      let!(:api)    { OandaApiV20::Api.new(client: client) }

      let(:response_account)  { '{"account":{"id":"100-100-100","NAV":"100000.0000","balance":"100000.0000","lastTransactionID":"99","orders":[],"positions":[],"trades":[],"pendingOrderCount":0},"lastTransactionID":"99"}' }
      let!(:request_account)  { stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100').to_return(status: 200, body: response_account, headers: {}) }

      let(:response_accounts) { '{"accounts":[{"id":"100-100-100","tags":[]}]}' }
      let!(:request_accounts) { stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').to_return(status: 200, body: response_accounts, headers: {}) }

      it 'makes a request to Oanda API' do
        api.accounts.show
        expect(request_accounts).to have_been_requested
        expect(request_accounts).to have_been_requested.at_most_once
      end

      it 'returns the response from Oanda API' do
        expect(api.accounts.show).to eq(JSON.parse(response_accounts))
        expect(api.account('100-100-100').show).to eq(JSON.parse(response_account))
      end
    end

    describe 'sets the correct HTTP verb' do
      let!(:client) { OandaApiV20::Client.new(access_token: 'my_access_token', base_uri: 'https://api-fxtrade.oanda.com/v3', headers: {}) }
      let!(:api)    { OandaApiV20::Api.new(client: client, account_id: '100-100-100') }

      context 'for GET' do
        let!(:request) { stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts') }

        it 'uses the correct HTTP verb' do
          api.accounts.show
          expect(request).to have_been_requested.once
        end

        it 'clears the HTTP verb attribute after use' do
          api.accounts.show
          expect(api.send(:http_verb)).to be_nil
        end
      end

      context 'for POST' do
        let!(:options) {
          {
            'order' => {
              'units' => '100',
              'instrument' => 'EUR_CAD',
              'timeInForce' => 'FOK',
              'type' => 'MARKET',
              'positionFill' => 'DEFAULT'
            }
          }
        }
        let!(:request) { stub_request(:post, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders').with(body: options) }

        it 'uses the correct HTTP verb' do
          api.order(options).create
          expect(request).to have_been_requested.once
        end

        it 'clears the HTTP verb attribute after use' do
          api.order(options).create
          expect(api.send(:http_verb)).to be_nil
        end
      end

      context 'for PATCH' do
        let!(:options) { { 'alias' => 'Timmy!' } }
        let!(:request) { stub_request(:patch, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/configuration').with(body: options) }

        it 'uses the correct HTTP verb' do
          api.configuration(options).update
          expect(request).to have_been_requested.once
        end

        it 'clears the HTTP verb attribute after use' do
          api.configuration(options).update
          expect(api.send(:http_verb)).to be_nil
        end
      end
    end
  end

  describe 'public methods' do
    let!(:client)        { OandaApiV20::Client.new(access_token: 'my_access_token') }
    let!(:api)           { OandaApiV20::Api.new(client: client) }
    let(:public_methods) { [
      :account, :accounts, :summary, :instruments, :changes, :configuration,
      :order, :orders, :pending_orders,
      :trade, :trades, :open_trades,
      :position, :positions, :open_positions,
      :transaction, :transactions, :transactions_id_range, :transactions_since_id,
      :transactions_stream,
      :pricing,
      :pricing_stream,
      :candles
    ] }

    it 'responds to all public methods' do
      public_methods.each do |public_method|
        expect(api.respond_to?(public_method)).to be_truthy
      end
    end

    it 'returns an OandaApiV20::Api instance when calling any of the public methods' do
      expect(api.accounts).to be_an_instance_of(OandaApiV20::Api)
    end

    it 'makes a request to Oanda API when calling any of the action methods' do
      request = stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts')
      api.accounts.show
      expect(request).to have_been_requested.once
    end
  end

  describe 'private methods' do
    describe '#set_http_verb' do
      let!(:client) { OandaApiV20::Client.new(access_token: 'my_access_token', base_uri: 'https://api-fxtrade.oanda.com/v3', headers: {}) }
      let!(:api)    { OandaApiV20::Api.new(client: client) }

      describe 'sets the correct HTTP verb' do
        it 'for GET' do
          api.send(:set_http_verb, :show, nil)
          expect(api.send(:http_verb)).to eq(:get)
        end

        it 'for POST' do
          api.send(:set_http_verb, :create, nil)
          expect(api.send(:http_verb)).to eq(:post)
        end

        it 'for PUT' do
          api.send(:set_http_verb, :update, nil)
          expect(api.send(:http_verb)).to eq(:put)
        end

        it 'for PUT' do
          api.send(:set_http_verb, :cancel, nil)
          expect(api.send(:http_verb)).to eq(:put)
        end

        it 'for PUT' do
          api.send(:set_http_verb, :close, nil)
          expect(api.send(:http_verb)).to eq(:put)
        end

        it 'for PATCH' do
          api.send(:set_http_verb, :update, :configuration)
          expect(api.send(:http_verb)).to eq(:patch)
        end

        it 'for POST' do
          api.send(:set_http_verb, :create, nil)
          expect(api.send(:http_verb)).to eq(:post)
        end
      end
    end

    describe '#set_last_action_and_arguments' do
      let!(:client) { OandaApiV20::Client.new(access_token: 'my_access_token', base_uri: 'https://api-fxtrade.oanda.com/v3', headers: {}) }
      let!(:api)    { OandaApiV20::Api.new(client: client) }

      it 'sets the last_action attribute' do
        api.send(:set_last_action_and_arguments, :accounts)
        expect(api.send(:last_action)).to eq(:accounts)
      end

      it 'sets the last_arguments attribute' do
        api.send(:set_last_action_and_arguments, :account, '100-100-100')
        expect(api.send(:last_arguments)).to eq(['100-100-100'])
      end
    end
  end
end
