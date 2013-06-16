Yet Another NS API [![Build Status](https://travis-ci.org/stefanhendriks/ns-api.png?branch=master)](https://travis-ci.org/stefanhendriks/ns-api) [![Coverage Status](https://coveralls.io/repos/stefanhendriks/ns-api/badge.png)](https://coveralls.io/r/stefanhendriks/ns-api)
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
First, make sure you have a username and password from the NS API website.
```ruby
require 'ns_client'

# get username/password from NS site
client = NSClient.new("my-username", "my-password")

# get all known stations
stations = client.stations
station = stations.first
station.name # 's-Hertogenbosch
station.lat # 51.69048
station.long # 5.29362

```

