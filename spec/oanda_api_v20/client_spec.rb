require 'spec_helper'

describe OandaApiV20::Client do
  describe '#initialize' do
    it 'sets the access_token attribute when supplied' do
      c = OandaApiV20::Client.new(access_token: 'my_access_token')
      expect(c.access_token).to eq('my_access_token')
    end

    it 'sets the proxy_url attribute when supplied' do
      c = OandaApiV20::Client.new(proxy_url: 'https://user:pass@proxy.com:80')
      expect(c.proxy_url).to eq('https://user:pass@proxy.com:80')
    end

    it 'sets the base_uri to practice when the practice option was supplied and set to true' do
      c = OandaApiV20::Client.new(practice: true)
      expect(c.base_uri).to eq('https://api-fxpractice.oanda.com/v3')
    end

    it 'sets the base_uri to live when the practice option was supplied and set to false' do
      c = OandaApiV20::Client.new(practice: false)
      expect(c.base_uri).to eq('https://api-fxtrade.oanda.com/v3')
    end

    it 'sets the base_uri to live when the practice option was not supplied' do
      c = OandaApiV20::Client.new
      expect(c.base_uri).to eq('https://api-fxtrade.oanda.com/v3')
    end

    it 'set the headers attribute to a hash' do
      c = OandaApiV20::Client.new
      expect(c.send(:headers)).to be_an_instance_of(Hash)
    end
  end

  describe '#method_missing' do
    let!(:c) { OandaApiV20::Client.new(access_token: 'my_access_token') }

    context 'when an OandaApiV20::Api method has been called' do
      it 'saves the method called' do
        c.accounts
        expect(c.send(:last_action)).to eq(:accounts)
      end

      it 'saves the attributes supplied' do
        c.account('100-100-100')
        expect(c.send(:last_action)).to eq(:account)
        expect(c.send(:last_arguments)).to eq(['100-100-100'])
      end

      it 'saves the account ID when calling the account method' do
        c.account('100-100-100')
        expect(c.send(:account_id)).to eq('100-100-100')
      end

      it 'returns a OandaApiV20::Client instance' do
        expect(c.account('100-100-100')).to be_an_instance_of(OandaApiV20::Client)
      end
    end

    context 'when an action method has been called' do
      let(:response_account)  { '{"account":{"id":"100-100-100","NAV":"100000.0000","balance":"100000.0000","lastTransactionID":"99","orders":[],"positions":[],"trades":[],"pendingOrderCount":0},"lastTransactionID":"99"}' }
      let!(:request_account)  { stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-100').to_return(status: 200, body: response_account, headers: {}) }

      let(:response_accounts) { '{"accounts":[{"id":"100-100-100","tags":[]}]}' }
      let!(:request_accounts) { stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').to_return(status: 200, body: response_accounts, headers: {}) }

      before(:each) do
        allow(c).to receive(:sleep)
      end

      describe 'network' do
        it 'makes a request to Oanda API' do
          c.accounts.show
          expect(request_accounts).to have_been_requested
          expect(request_accounts).to have_been_requested.at_most_once
        end

        it 'returns the response from Oanda API' do
          expect(c.accounts.show).to eq(JSON.parse(response_accounts))
          expect(c.account('100-100-100').show).to eq(JSON.parse(response_account))
        end
      end

      describe 'attributes' do
        it 'sets the equivalent HTTP verb' do
          c.accounts.show
          expect(c.send(:http_verb)).to eq(:get)
        end

        it 'sets the current account ID' do
          c.account('100-100-100').show
          expect(c.send(:account_id)).to eq('100-100-100')
        end

        it 'sets the last transaction ID when returned' do
          c.account('100-100-100').show
          expect(c.send(:last_transaction_id)).to eq('99')
        end

        it 'sets the last request made at time' do
          expect(c.send(:last_api_request_at).last).to be_nil
          c.accounts.show
          expect(c.send(:last_api_request_at).last).to_not be_nil
          expect(Time.parse(c.send(:last_api_request_at).last.to_s)).to be_an_instance_of(Time)
        end
      end

      describe 'headers' do
        it 'sets authentication header' do
          c.accounts.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').with(headers: { 'Authorization' => 'Bearer my_access_token' })).to have_been_made.once
        end

        it 'sets content type header to json' do
          c.accounts.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').with(headers: { 'Content-Type' => 'application/json' })).to have_been_made.once
        end

        it 'sets date time format header to RFC3339' do
          c.accounts.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').with(headers: { 'X-Accept-Datetime-Format' => 'RFC3339' })).to have_been_made.once
        end

        it 'sets persisten connection header' do
          c.accounts.show
          expect(a_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts').with(headers: { 'Connection' => 'keep-alive' })).to have_been_made.once
        end
      end

      describe 'exceptions' do
        it 'raises an OandaApiV20::RequestError exception when receiving anything other than a 2xx response from Oanda API' do
          stub_request(:get, 'https://api-fxtrade.oanda.com/v3/accounts/100-100-109').to_return(status: 401, body: '', headers: {})
          expect{ c.account('100-100-109').show }.to raise_error(OandaApiV20::RequestError)
        end
      end

      describe 'governing request rate' do
        before(:each) do
          Timecop.freeze(Time.local('2016-08-01 06:00:00'))
        end

        after(:each) do
          Timecop.return
        end

        it 'is not allowed to make 30 requests or more per second' do
          expect(c).to receive(:sleep).at_least(:twice)
          30.times { c.accounts.show }
          Timecop.freeze('2016-08-01 06:00:01')
          30.times { c.accounts.show }
        end

        it 'is allowed to make less than 30 requests per second' do
          expect(c).to_not receive(:sleep)
          29.times { c.accounts.show }
          Timecop.freeze('2016-08-01 06:00:01')
          29.times { c.accounts.show }
          Timecop.freeze('2016-08-01 06:00:02')
          29.times { c.accounts.show }
        end

        it 'halts all API requests for the remainder of the second when 30 requests have been made in one second' do
          expect(c).to receive(:sleep).with(0.7)
          Timecop.freeze('2016-08-01 06:00:00.0')
          10.times { c.accounts.show }
          Timecop.freeze('2016-08-01 06:00:00.1')
          10.times { c.accounts.show }
          Timecop.freeze('2016-08-01 06:00:00.3')
          10.times { c.accounts.show }
        end
      end
    end

    context 'when a method other than an OandaApiV20::Api method has been called' do
      it 'throws a NoMethodError exception' do
        expect{ c.accounts.show_me_the_money }.to raise_error(NoMethodError)
      end
    end

    context 'when a method other than an action method has been called' do
      it 'throws a NoMethodError exception' do
        expect{ c.this_method_definitely_does_not_exist }.to raise_error(NoMethodError)
      end
    end
  end
end
