require 'spec_helper'

describe OandaApiV20::Client do
  describe '#initialize' do
    it 'sets the access_token attribute when supplied' do
      client = OandaApiV20::Client.new(access_token: 'my_access_token')
      expect(client.access_token).to eq('my_access_token')
    end

    it 'sets the connection_pool_size attribute when supplied' do
      client = OandaApiV20::Client.new(connection_pool_size: 5)
      expect(client.connection_pool_size).to eq(5)
    end

    it 'sets the connection_pool_size attribute to the default value of 2 when not supplied' do
      client = OandaApiV20::Client.new
      expect(client.connection_pool_size).to eq(2)
    end

    it 'sets the max_requests_per_second attribute when supplied' do
      client = OandaApiV20::Client.new(max_requests_per_second: 10)
      expect(client.max_requests_per_second).to eq(10)
    end

    it 'sets the max_requests_per_second attribute to the default value of 100 when not supplied' do
      client = OandaApiV20::Client.new
      expect(client.max_requests_per_second).to eq(100)
    end

    it 'sets the proxy_url attribute when supplied' do
      client = OandaApiV20::Client.new(proxy_url: 'https://user:pass@proxy.com:80')
      expect(client.proxy_url).to eq('https://user:pass@proxy.com:80')
    end

    it 'sets the base_uri to practice when the practice option was supplied and set to true' do
      client = OandaApiV20::Client.new(practice: true)
      expect(client.base_uri).to eq('https://api-fxpractice.oanda.com/v3')
    end

    it 'sets the base_uri to live when the practice option was supplied and set to false' do
      client = OandaApiV20::Client.new(practice: false)
      expect(client.base_uri).to eq('https://api-fxtrade.oanda.com/v3')
    end

    it 'sets the base_uri to live when the practice option was not supplied' do
      client = OandaApiV20::Client.new
      expect(client.base_uri).to eq('https://api-fxtrade.oanda.com/v3')
    end

    it 'set the headers attribute to a hash' do
      client = OandaApiV20::Client.new
      expect(client.send(:headers)).to be_an_instance_of(Hash)
    end
  end

  describe '#method_missing' do
    let!(:client) { OandaApiV20::Client.new(access_token: 'my_access_token') }

    it 'returns an OandaApiV20::Api instance when an API method has been called' do
      expect(client.accounts).to be_an_instance_of(OandaApiV20::Api)
    end

    it 'sets the OandaApiV20::Api account_id attribute when method account was called' do
      expect(client.account('100-100-100').account_id).to eq('100-100-100')
    end

    it 'sets the OandaApiV20::Api intrument variable when method instrument was called' do
      instrument = 'EUR_USD'
      expect(client.instrument(instrument).instance_variable_get(:@instrument)).to eq(instrument)
    end

    it 'raises a NoMethodError exception when a method other than an OandaApiV20::Api method has been called' do
      expect{ client.this_method_definitely_does_not_exist }.to raise_error(NoMethodError)
    end

    it 'raises a NoMethodError exception when a method other than an OandaApiV20::Api action method has been called' do
      expect{ client.accounts.show_me_the_money }.to raise_error(NoMethodError)
    end

    context 'network' do
      let(:response_account)  { '{"account":{"id":"100-100-100","NAV":"100000.0000","balance":"100000.0000","lastTransactionID":"99","orders":[],"positions":[],"trades":[],"pendingOrderCount":0},"lastTransactionID":"99"}' }
      let!(:request_account)  { stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100').to_return(status: 200, body: response_account, headers: {}) }

      let(:response_accounts) { '{"accounts":[{"id":"100-100-100","tags":[]}]}' }
      let!(:request_accounts) { stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').to_return(status: 200, body: response_accounts, headers: {}) }

      before(:each) do
        allow(client).to receive(:sleep)
      end

      it 'raises an OandaApiV20::RequestError exception when receiving anything other than a 2xx response from Oanda API' do
        stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-109').to_return(status: 401, body: '', headers: {})
        expect{ client.account('100-100-109').show }.to raise_error(OandaApiV20::RequestError)
      end

      describe 'headers' do
        it 'sets authentication header' do
          client.accounts.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').with(headers: { 'Authorization' => 'Bearer my_access_token' })).to have_been_made.once
        end

        it 'sets content type header to json' do
          client.accounts.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').with(headers: { 'Content-Type' => 'application/json' })).to have_been_made.once
        end

        it 'sets date time format header to RFC3339' do
          client.accounts.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').with(headers: { 'X-Accept-Datetime-Format' => 'RFC3339' })).to have_been_made.once
        end

        it 'sets persisten connection header' do
          client.accounts.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').with(headers: { 'Connection' => 'keep-alive' })).to have_been_made.once
        end
      end
    end
  end

  describe 'public methods' do
    let!(:client) { OandaApiV20::Client.new(access_token: 'my_access_token') }

    let(:response_account)  { '{"account":{"id":"100-100-100","NAV":"100000.0000","balance":"100000.0000","lastTransactionID":"99","orders":[],"positions":[],"trades":[],"pendingOrderCount":0},"lastTransactionID":"99"}' }
    let!(:request_account)  { stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100').to_return(status: 200, body: response_account, headers: {}) }

    let(:response_accounts) { '{"accounts":[{"id":"100-100-100","tags":[]}]}' }
    let!(:request_accounts) { stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').to_return(status: 200, body: response_accounts, headers: {}) }

    before(:each) do
      allow(client).to receive(:sleep)
    end

    describe '#govern_api_request_rate' do
      before(:each) do
        Timecop.freeze(Time.local('2016-08-01 06:00:00'))
      end

      after(:each) do
        Timecop.return
      end

      it 'is not allowed to make 100 requests or more per second' do
        expect(client).to receive(:sleep).at_least(:twice)
        100.times { client.accounts.show }
        Timecop.freeze('2016-08-01 06:00:01')
        100.times { client.accounts.show }
      end

      it 'is allowed to make less than 100 requests per second' do
        expect(client).to_not receive(:sleep)
        99.times { client.accounts.show }
        Timecop.freeze('2016-08-01 06:00:01')
        99.times { client.accounts.show }
        Timecop.freeze('2016-08-01 06:00:02')
        99.times { client.accounts.show }
      end

      it 'halts all API requests for the remainder of the second when 100 requests have been made in one second' do
        expect(client).to receive(:sleep).with(0.7)
        Timecop.freeze('2016-08-01 06:00:00.0')
        30.times { client.accounts.show }
        Timecop.freeze('2016-08-01 06:00:00.1')
        30.times { client.accounts.show }
        Timecop.freeze('2016-08-01 06:00:00.3')
        40.times { client.accounts.show }
      end
    end

    describe '#update_last_api_request_at' do
      it 'sets the time of the last request made' do
        expect(client.send(:last_api_request_at).last).to be_nil
        client.accounts.show
        expect(client.send(:last_api_request_at).last).to_not be_nil
        expect(Time.parse(client.send(:last_api_request_at).last.to_s)).to be_an_instance_of(Time)
      end
    end
  end
end
