require 'spec_helper'

describe OandaApiV20::Api do
  describe '#initialize' do
    it 'sets the http_verb attribute when supplied' do
      api = OandaApiV20::Api.new(http_verb: :post)
      expect(api.http_verb).to eq(:post)
    end

    it 'sets the base_uri attribute when supplied' do
      url = 'https://api-fxpractice.oanda.com/v3'
      api = OandaApiV20::Api.new(base_uri: url)
      expect(api.base_uri).to eq(url)
    end

    it 'sets the headers attribute when supplied' do
      headers = { 'Content-Type' => 'application/json', 'Connection' => 'keep-alive', 'Keep-Alive' => '30' }
      api = OandaApiV20::Api.new(headers: headers)
      expect(api.headers).to eq(headers)
    end

    it 'sets the account_id attribute when supplied' do
      account_id = '100-100-100'
      api = OandaApiV20::Api.new(account_id: account_id)
      expect(api.account_id).to eq(account_id)
    end

    it 'sets the last_transaction_id attribute when supplied' do
      last_transaction_id = '1'
      api = OandaApiV20::Api.new(last_transaction_id: last_transaction_id)
      expect(api.last_transaction_id).to eq(last_transaction_id)
    end
  end

  describe '#public_methods' do
    let!(:api)           { OandaApiV20::Api.new }
    let(:public_methods) { [
      :account, :accounts, :summary, :instruments, :changes, :configuration,
      :order, :orders, :pending_orders,
      :trade, :trades, :open_trades,
      :position, :positions, :open_positions,
      :transaction, :transactions, :transactions_id_range, :transactions_since_id,
      :pricing
    ] }

    it 'responds to all public methods' do
      public_methods.each do |public_method|
        expect(api.respond_to?(public_method)).to be_truthy
      end
    end
  end

  describe 'constructs the correct API URL under' do
    let!(:api) { OandaApiV20::Api.new(base_uri: 'https://api-fxtrade.oanda.com/v3', account_id: '100-100-100', headers: {}) }

    before(:each) do
      stub_request(:any, /https:\/\/api-fxtrade\.oanda\.com\/v3.*/)
      api.http_verb = :get
    end

    context 'accounts for' do
      it 'retrieving an account' do
        api.account('100-100-100')
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100')).to have_been_made.once
      end

      it 'retrieving all accounts' do
        api.accounts
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts')).to have_been_made.once
      end

      it 'retrieving a summary' do
        api.summary
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/summary')).to have_been_made.once
      end

      it 'retrieving all instruments' do
        api.instruments
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/instruments')).to have_been_made.once
      end

      it 'retrieving an instrument' do
        api.instruments('EUR_USD')
        options = { 'instruments' => 'EUR_USD' }
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/instruments').with(query: options)).to have_been_made.once
      end

      it 'retrieving all changes' do
        api.last_transaction_id = '1'
        api.changes
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/changes').with(query: { 'sinceTransactionID' => '1' })).to have_been_made.once
      end

      it 'retrieving all changes since a transaction id' do
        options = {
          'sinceTransactionID' => '1'
        }
        api.changes(options)
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/changes').with(query: options)).to have_been_made.once
      end

      it 'updating a configuration' do
        api.http_verb = :patch
        options = { 'alias' => 'Timmy!' }
        api.configuration(options)
        expect(a_request(:patch, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/configuration').with(body: options.to_json))
      end
    end

    context 'instruments for' do
      let!(:api) { OandaApiV20::Api.new(base_uri: 'https://api-fxtrade.oanda.com/v3', account_id: '100-100-100', instrument: 'EUR_USD', headers: {}) }

      it 'retrieving candlestick data' do
        options = { 'count' => '10' }
        api.candles(options)
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/instruments/EUR_USD/candles').with(query: options)).to have_been_made.once
      end
    end

    context 'orders for' do
      it 'retrieving an order' do
        api.order('1')
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders/1')).to have_been_made.once
      end

      it 'creating an order' do
        api.http_verb = :post
        options = {
          'order' => {
            'units' => '100',
            'instrument' => 'EUR_CAD',
            'timeInForce' => 'FOK',
            'type' => 'MARKET',
            'positionFill' => 'DEFAULT'
          }
        }
        api.order(options)
        expect(a_request(:post, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders').with(body: options.to_json)).to have_been_made.once
      end

      it 'updating an order' do
        api.http_verb = :put
        options = {
          'order' => {
            'timeInForce' => 'GTC',
            'price' => '1.7000',
            'type' => 'TAKE_PROFIT',
            'tradeID' => '1'
          }
        }
        api.order('1', options)
        expect(a_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders/1').with(body: options.to_json)).to have_been_made.once
      end

      it 'updating an order client extensions' do
        api.http_verb = :put
        options = {
          'clientExtensions' => {
            'comment' => 'New comment for my limit order'
          }
        }
        api.order('1', options)
        expect(a_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders/1/clientExtensions').with(body: options.to_json)).to have_been_made.once
      end

      it 'cancelling an order' do
        api.http_verb = :put
        api.order('1')
        expect(a_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders/1/cancel')).to have_been_made.once
      end

      it 'retrieving all orders' do
        api.orders
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/orders')).to have_been_made.once
      end

      it 'retrieving all pending orders' do
        api.pending_orders
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/pendingOrders')).to have_been_made.once
      end
    end

    context 'trades for' do
      it 'retrieving a trade' do
        api.trade('1')
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades/1')).to have_been_made.once
      end

      it 'updating a trade' do
        api.http_verb = :put
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
        api.trade('1', options)
        expect(a_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades/1/orders').with(body: options.to_json)).to have_been_made.once
      end

      it 'updating a trade client extensions' do
        api.http_verb = :put
        options = {
          'clientExtensions' => {
            'comment' => 'This is a USD/CAD trade',
            'tag' => 'trade tag',
            'id' => 'my_usd_cad_trade'
          }
        }
        api.trade('1', options)
        expect(a_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades/1/clientExtensions').with(body: options.to_json)).to have_been_made.once
      end

      it 'closing a trade' do
        api.http_verb = :put
        api.trade('1')
        expect(a_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades/1/close')).to have_been_made.once
      end

      it 'closing a trade partially' do
        api.http_verb = :put
        options = { 'units' => '10' }
        api.trade('1', options)
        expect(a_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades/1/close')).to have_been_made.once
      end

      it 'retrieving all trades' do
        options = { 'instrument' => 'USD_CAD' }
        api.trades(options)
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/trades').with(query: options)).to have_been_made.once
      end

      it 'retrieving all open trades' do
        api.open_trades
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/openTrades')).to have_been_made.once
      end
    end

    context 'positions for' do
      it 'retrieving a position' do
        api.position('EUR_USD')
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/positions/EUR_USD')).to have_been_made.once
      end

      it 'retrieving all positions' do
        api.positions
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/positions')).to have_been_made.once
      end

      it 'retrieving all open positions' do
        api.open_positions
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/openPositions')).to have_been_made.once
      end

      it 'closing a position' do
        api.http_verb = :put
        options = { 'longUnits' => 'ALL' }
        api.position('EUR_CAD', options)
        expect(a_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/positions/EUR_CAD/close').with(body: options.to_json)).to have_been_made.once
      end

      it 'closing a position partially' do
        api.http_verb = :put
        options = { 'longUnits' => '99' }
        api.position('EUR_CAD', options)
        expect(a_request(:put, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/positions/EUR_CAD/close').with(body: options.to_json)).to have_been_made.once
      end
    end

    context 'transactions for' do
      it 'retrieving a transaction' do
        api.transaction('1')
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/transactions/1')).to have_been_made.once
      end

      it 'retrieving all transactions' do
        api.transactions
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/transactions')).to have_been_made.once
      end

      it 'retrieving all transactions in date range' do
        options = {
          'from' => '2016-08-01T02:00:00Z',
          'to' => '2016-08-15T02:00:00Z'
        }
        api.transactions(options)
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/transactions').with(query: options)).to have_been_made.once
      end

      it 'retrieving all transactions in an id range' do
        options = {
          'from' => '6409',
          'to' => '6412'
        }
        api.transactions_id_range(options)
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/transactions/idrange').with(query: options)).to have_been_made.once
      end

      it 'retrieving all transactions since an id' do
        options = {
          'id' => '6411'
        }
        api.transactions_since_id(options)
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/transactions/sinceid').with(query: options)).to have_been_made.once
      end
    end

    context 'pricing for' do
      it 'retrieving all pricing' do
        options = {
          'instruments' => 'EUR_USD,USD_CAD'
        }
        api.pricing(options)
        expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100/pricing').with(query: options)).to have_been_made.once
      end
    end
  end
end
