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

```ruby
client.accounts.show
```

```ruby
client.account('account_id').show
```

```ruby
client.account('account_id').summary.show
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
- Persistent connections using persistent_httparty.
- No more than 2 connections per second.
- Limit to 30 requests per second.
