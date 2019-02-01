require 'spec_helper'

describe OandaApiV20::RequestError do
  describe '#initialize' do
    let(:response)           { { code: 200, body: '' } }

    it 'sets the message attribute' do
      exception = OandaApiV20::RequestError.new('An error as occured while processing response.')
      expect(exception.message).to eq('An error as occured while processing response.')
    end

    it 'sets the response attribute when supplied' do
      exception = OandaApiV20::RequestError.new('An error as occured while processing response.', response: response)
      expect(exception.response).to eq(response)
    end

    it 'sets the original_exception attribue when supplied' do
      original_exception = OpenSSL::SSL::SSLError.new('SSL_read: sslv3 alert handshake failure')
      exception = OandaApiV20::RequestError.new('An error as occured while processing response.', original_exception: original_exception)
      expect(exception.original_exception).to be_an_instance_of(OpenSSL::SSL::SSLError)
      expect(exception.original_exception.message).to eq('SSL_read: sslv3 alert handshake failure')
    end
  end
end
