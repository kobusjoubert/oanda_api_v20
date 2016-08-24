$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'oanda_api_v20/version'
require 'time'

Gem::Specification.new do |s|
  s.name        = 'oanda_api_v20'
  s.version     = OandaApiV20::VERSION
  s.date        = Date.today.to_s
  s.summary     = %q{Ruby Oanda REST API V20}
  s.description = %q{Ruby client that supports the Oanda REST API V20 methods.}
  s.authors     = ['Kobus Joubert']
  s.email       = 'kobus@translate3d.com'
  s.homepage    = 'http://rubygems.org/gems/oanda_api_v20'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'httparty',            '~> 0.13'
  s.add_dependency 'persistent_httparty', '~> 0.1'
  s.add_dependency 'http-exceptions',     '~> 0.1'

  s.add_development_dependency 'rspec',   '~> 3.4'
  s.add_development_dependency 'webmock', '~> 2.1'
  s.add_development_dependency 'timecop', '~> 0.8'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
end
