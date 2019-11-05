# Change Log

## 2.1.1
#### 2019-10-05
* Fix to pricing_stream method. This fixes the currency pair rate being reused over and over no matter the value read in the HTTP chunk. Big thanks to @joseluis-fw & @salrepe.

## 2.1.0
#### 2019-02-01
* New pricing_stream endpoint. Big thanks to @joseluis-fw.
* Raises an OandaApiV20::ParseError exception when a malformed response returned from Oanda API.
* The OandaApiV20::RequestError exception object now has an original_exception attribute which contains the original exception object raised.

## 2.0.0
#### 2018-04-24
* Fixed issues when trying to reuse a Client object to make HTTP requests to Oanda.
* Moved instance variables last_action, last_arguments, instrument and account_id from the Client class to the Api class. They should not be part of a Client object.
* Removed last_transaction_id instance variable.
* RubyVM::Logger changed to ::Logger.
* Added a connection_pool_size option to allow persistent HTTP connection control on the Client object.
* Added a max_requests_per_second option to allow customized control on the Client max requests per second allowed to Oanda API.
* Added multithreading support for HTTP request governing. HTTP requests will be correctly allocated across multiple client threads.
* Raises an OandaApiV20::ApiError exception when no client object was supplied when instantiating an OandaApiV20::Api instance.

## 1.5.0
#### 2017-07-07
* Updated the orders method to allow query options to be passed along.

## 1.4.0
#### 2017-06-04
* Ability for API requests to go through a proxy.

## 1.3.0
#### 2017-03-16
* Updated the account method to allow query options to be passed along.

## 1.2.0
#### 2016-12-03
* Added the instruments method to retrieve candlestick data.

## 1.1.0
#### 2016-10-24
* Added an optional field to the account instruments method to query only a list of instruments instead of returning all instruments.

## 1.0.0
#### 2016-08-23
* Added the RSpec Gem for writing unit tests.
* Added the WebMock Gem to stub HTTP requests to Oanda API when writing unit tests.
* Raises a NoMethodError exception when the method does not exist. Previously nil was returned.
* Raises an OandaApiV20::RequestError exception when the status code is not 2xx.
* Fixed an issue where the requests to Oanda API was limited to 30 requests per minute instead of 30 requests per second. Whoops!
* Fixed a bug where the response body would sometimes be nil and cause the client to crash.

## 0.0.6
#### 2016-08-18
* HTTP exception handling added.

## 0.0.5
#### 2016-08-16
* Added the Gemfile to allow the 'bundle install' command to work.

## 0.0.4
#### 2016-08-16
* Limit Oanda API requests to 30 per second.

## 0.0.3
#### 2016-08-14
* Persistent HTTP connections using the persistent_httparty Gem.

## 0.0.2
#### 2016-08-12
* README Documentation added.

## 0.0.1
#### 2016-08-09
* Functions to map to the Oanda API endpoints.
* Setting up gemspec file.
* Added gitignore.
* Added LICENSE.
* Added README.md.

## 0.0.0
#### 2016-06-16
* Initial commit.
