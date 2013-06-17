Yet Another NS API [![Build Status](https://travis-ci.org/stefanhendriks/ns-api.png?branch=master)](https://travis-ci.org/stefanhendriks/ns-api) [![Coverage Status](https://coveralls.io/repos/stefanhendriks/ns-api/badge.png)](https://coveralls.io/r/stefanhendriks/ns-api) [![Dependency Status](https://gemnasium.com/stefanhendriks/ns-api.png)](https://gemnasium.com/stefanhendriks/ns-api)
==================
A Ruby client for the NS API.

Goal
====
I'd like to write a comprehensive, yet very thin implementation of the NS API. For now I have limited access therefor this gem is limited.

If you have credentials that work with the prices-api calls, and are willing to share them with me so I can expand this gem. Please contact me.

You can also send me an example response, so I can work from there. Although I would like to see it working for real as well.

Pull requests are welcome.

Usage
=====
First, make sure you have a username and password from the NS API website. (at: http://www.ns.nl/api)

You can use the NSYAPI singleton, you can configure it by using a configuration block:
```ruby
require 'ns_client'

NSYapi::configure do |config|
  config.username = "some-username"
  config.password = "some-password"
end

client = NSYapi::client

client.stations
```

or, you can instantiate the NSClient yourself, providing a username and password. You can then regulate the instance yourself.

```ruby
require 'ns_client'

# get username/password from NS site
client = NSClient.new("my-username", "my-password")

```

After you have created a client, you can use it for several operations

Retrieve all stations
=====================

```ruby
# get all known stations
stations = client.stations
station = stations.first
station.name # 's-Hertogenbosch
station.lat # 51.69048
station.long # 5.29362
```

Retrieve disruptions
====================
```ruby
# get all known disruptions
disruptions = client.disruptions

# get planned disruptions
planned = disruptions[:planned]

# get unplanned disruptions
unplanned = disruptions[:unplanned]

# get disruptions from specific station, ie Amsterdam
disruptions = client.disruptions "Amsterdam"
```
