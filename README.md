abn_search [![CircleCI](https://circleci.com/gh/Oneflare/abn_search/tree/master.svg?style=svg&circle-token=4ecf3e2c7e6e97f96ab1b19b9ed0dbba44efa121)](https://circleci.com/gh/Oneflare/abn_search/tree/master) [![Coverage Status](https://coveralls.io/repos/github/Oneflare/abn_search/badge.svg?branch=master)](https://coveralls.io/github/Oneflare/abn_search?branch=master)
================
A simple ABN search library for validating and obtaining ABN details from the Australian Business Register.

## Setup

#### Dependencies
* Ruby 2.0 +

* bundler

#### ABR GUID
You will need a GUID to be able to use the ABR business lookup API. You can obtain one at the following link;
http://abr.business.gov.au/Documentation/UserGuideWebRegistration.aspx

#### Rails Installation
Simply add the following line to your Gemfile and run bundle install.

```ruby
gem 'abn_search'
```

## Tests
You can run the test suite with
```bash
bundle exec rake
```
or
```bash
bundle exec rake rspec
```

Please ensure that you write tests for any commits, and that tests pass locally before you submit a PR.

## Usage

#### To start IRB with the gem
```bash
bundle exec rake console
```

#### Set up a client
```ruby
client = Abn::Client.new("YOUR_GUID_HERE")
```

#### Search by ABN Number
```ruby
result = client.search("59001215354")
# => {:acn=>"001215354", ":abn=>"59001215354", :entity_type=>"Australian Public Company", :status=>"Active", :main_name=>"SONY AUSTRALIA LIMITED", :trading_name=>"", :legal_name=>"", :other_trading_name=>"", :name=>"SONY AUSTRALIA LIMITED"}

puts result[:entity_type]
# => "Australian Public Company"

puts result[:status]
# => "Active"

puts result[:name]
# => "SONY AUSTRALIA LIMITED"
```

#### Search by ACN Number
```ruby
result = client.search_by_acn("001215354")
# => {:acn=>"001215354", ":abn=>"59001215354", :entity_type=>"Australian Public Company", :status=>"Active", :main_name=>"SONY AUSTRALIA LIMITED", :trading_name=>"", :legal_name=>"", :other_trading_name=>"", :name=>"SONY AUSTRALIA LIMITED"}
```

#### Search by name
```ruby
results = client.search_by_name("Sony", ['NSW'], '2000')
results.each do |result|
  puts result[:name]
end
```

## Errors
If an ABN is missing, invalid or expired - check the errors attribute.

```ruby
client.errors
# => ["Business ABN 89107860122 has expired."]
```

## External Resources
- [Australian Business Register](https://www.abr.business.gov.au/)
- [ABR ABN Lookup Web services documentation](https://abr.business.gov.au/Documentation/Index)
- [XML API WSDL](https://abr.business.gov.au/abrxmlsearch/abrxmlsearch.asmx)
- [GUID Registration link](https://abr.business.gov.au/Documentation/UserGuideWebRegistration.aspx)
