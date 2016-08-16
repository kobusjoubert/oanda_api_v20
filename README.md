# OandaApiV20

[![Gem Version](https://badge.fury.io/rb/oanda_api_v20.svg)](https://rubygems.org/gems/oanda_api_v20)

Ruby client that supports the Oanda REST API V20 methods.

## Installation

Add this line to your application's Gemfile:

    gem 'oanda_api_v20'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oanda_api_v20

## Usage

Add the following to your ruby program:

    require 'oanda_api_v20'

Initialise a client:

    client = OandaApiV20.new(access_token: 'my_access_token')

If you would like to trade with your test account:

    client = OandaApiV20.new(access_token: 'my_access_token', practice: true)

## Examples

### Accounts

See the [Oanda Documentation](http://developer.oanda.com/rest-live-v20/account-ep/) for all available options on accounts.

```ruby
client.accounts.show
```

```ruby
client.account('account_id').show
```

```ruby
client.account('account_id').summary.show
```

```ruby
client.account('account_id').instruments.show
```

```ruby
client.account('account_id').changes.show
```

```ruby
options = { alias: 'My New Account #2' }

client.account('account_id').configuration(options).update
```

### Orders

See the [Oanda Documentation](http://developer.oanda.com/rest-live-v20/orders-ep/) for all available options on orders.

```ruby
client.account('account_id').orders.show
```

```ruby
id = client.account('account_id').orders.show['orders'][0]['id']

client.account('account_id').order(id).show
```

```ruby
options = {
  'order' => {
    'units' => '100',
    'instrument' => 'EUR_CAD',
    'timeInForce' => 'FOK',
    'type' => 'MARKET',
    'positionFill' => 'DEFAULT'
  }
}

client.account('account_id').order(options).create
```

```ruby
id = client.account('account_id').orders.show['orders'][0]['id']

options = {
  'order' => {
    'timeInForce' => 'GTC',
    'price' => '1.7000',
    'type' => 'TAKE_PROFIT',
    'tradeID' => '1'
  }
}

client.account('account_id').order(id, options).update
```

```ruby
id = client.account('account_id').orders.show['orders'][0]['id']

client.account('account_id').order(id).cancel
```

### Trades

See the [Oanda Documentation](http://developer.oanda.com/rest-live-v20/trades-ep/) for all available options on trades.

```ruby
options = { 'instrument' => 'USD_CAD' }

client.account('account_id').trades(options).show
```

```ruby
client.account('account_id').open_trades.show
```

```ruby
id = client.account('account_id').open_trades.show['trades'][0]['id']

client.account('account_id').trade(id).show
```

```ruby
id = client.account('account_id').open_trades.show['trades'][0]['id']

options = {
  'clientExtensions' => {
    'comment' => 'This is a USD/CAD trade',
    'tag' => 'trade tag',
    'id' => 'my_usd_cad_trade'
  }
}

client.account('account_id').trade(id, options).update
```

```ruby
id = client.account('account_id').open_trades.show['trades'][0]['id']

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

client.account('account_id').trade(id, options).update
```

```ruby
id = client.account('account_id').open_trades.show['trades'][0]['id']

options = { 'units' => '10' }

client.account('account_id').trade(id, options).close
```

```ruby
id = client.account('account_id').open_trades.show['trades'][0]['id']

client.account('account_id').trade(id).close
```

### Positions

See the [Oanda Documentation](http://developer.oanda.com/rest-live-v20/positions-ep/) for all available options on positions.

```ruby
client.account('account_id').positions.show
```

```ruby
client.account('account_id').open_positions.show
```

```ruby
client.account('account_id').position('EUR_USD').show
```

```ruby
options = { 'longUnits' => 'ALL' }

client.account('account_id').position('EUR_CAD', options).close
```

### Transactions

See the [Oanda Documentation](http://developer.oanda.com/rest-live-v20/transactions-ep/) for all available options on transactions.

```ruby
client.account('account_id').transactions.show
```

```ruby
options = {
  'from' => '2016-08-01T02:00:00Z',
  'to' => '2016-08-15T02:00:00Z'
}

client.account('account_id').transactions(options).show
```

```ruby
id = 6410

client.account('account_id').transaction(id).show
```

```ruby
options = {
  'from' => '6409',
  'to' => '6412'
}

client.account('account_id').transactions_id_range(options).show
```

```ruby
options = {
  'id' => '6411'
}

client.account('account_id').transactions_since_id(options).show
```

### Pricing

See the [Oanda Documentation](http://developer.oanda.com/rest-live-v20/pricing-ep/) for all available options on pricing.

```ruby
options = {
  'instruments' => 'EUR_USD,USD_CAD'
}

client.account('account_id').pricing(options).show
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

There are still a lot to be added to this gem:

- Unit tests using RSpec.
- ...
