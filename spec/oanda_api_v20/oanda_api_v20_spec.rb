require 'spec_helper'

describe OandaApiV20 do
  describe '.new' do
    it 'instantiates a new OandaApiV20::Client' do
      client = OandaApiV20.new
      expect(client).to be_an_instance_of(OandaApiV20::Client)
    end
  end
end
