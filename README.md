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

If you find it too tedious ploughing through all objects in the array, you can also use the ```stations_short``` method. This will return a hash with the station code as key, the
value is an array with the name and country of the station.

```ruby
client.stations_short
 => {"HT"=>["'s-Hertogenbosch", "NL"], "HTO"=>["Hertogenbosch O.", "NL"], "HDE"=>["'t Harde", "NL"], "AHBF"=>["Aachen", "D"], "ARE"=>["Aachen R. Erde", "D"], "ASCH"=>["Aachen Schanz", "D"], "AW"=>["Aachen-West", "D"], "ATN"=>["Aalten", "NL"], "AC"=>["Abcoude", "NL"], "EAHS"=>["Ahaus", "D"], "AIME"=>["Aime-la-Plagne", "F"], "AIXTGV"=>["Aix-en-Provence", "F"], "AKM"=>["Akkrum", "NL"], "ALBERT"=>["Albertville", "F"], "ALESS"=>["Alessandria", "I"], "AMR"=>["Alkmaar", "NL"], "AMRN"=>["Alkmaar Noord", "NL"], "AML"=>["Almelo", "NL"], "AMRI"=>["Almelo de Riet", "NL"], "ALMB"=>["Almere Buiten", "NL"], "ALM"=>["Almere C.", "NL"], "ALMM"=>["Muziekwijk", "NL"], "ALMO"=>["Oostvaarders", "NL"], "ALMP"=>["Parkwijk", "NL"], "AMPO"=>["Poort", "NL"], "APN"=>["Alphen a/d Rijn", "NL"], "EABG"=>["Altenberge", "D"], "AMF"=>["Amersfoort", "NL"], "AMFS"=>["Schothorst", "NL"]....
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

# get disruptions from specific station, ie Amsterdam (case insensitive)
disruptions = client.disruptions "Amsterdam"

# will raise an NSClient::InvalidStationNameError error when station name is invalid
client.disruptions "bla" # NSClient::InvalidStationNameError: Could not find a station with name 'bla'
```

Retrieve prices
===============
Prices can be retrieved by using a valid ```from```,```to```,```via``` parameter. You can use the name of the station or the code. (as you can see above with the stations calls)

```ruby
# retrieving prices requires a from and to at minimum. Which assumes prices for today
prices = client.prices from: "Amsterdam Centraal", to: "Purmerend"

# if you'd rather retrieve prices for a specific date, this is an optional parameter. If not given, today is assumed.
tomorrow = Date.today + 1.day
prices_tomorrow = client.prices from: "Amsterdam Centraal", to: "Purmerend", date: tomorrow

# you can specify a via option, this is also optional
prices_via = client.prices from: "Amsterdam Centraal", to: "Purmerend", via: "Zaandam"

# retrieve prices for tomorrow, via specific station
prices_via_tomorrow = client.prices from: "Amsterdam Centraal", to: "Purmerend", via: "Zaandam", date: tomorrow

# Using an invalid station name will result in a...
# NSClient::InvalidStationNameError: 'Amsterdam' is not a valid station name
prices = client.prices from: "Amsterdam", to "Purmerend"

```

Prices Response data
--------------------
A prices response is an object PricesResponse, which contains tariffunits (a measurement for cost-distance) and a hash with prices.

Each key in this hash is the type of prices (ie 'Dagretour', or 'Enkele reis').

In case different types would be added by the NS, than this API will simply add them to the hash, which makes it quite flexible.

```ruby
prices = client.prices from: "Amsterdam Centraal", to: "Purmerend"

# show tarif units (tariefeenheden)
prices.tariff_units # 10

# show prices for "Dagretour", easy method
dagretour_prices = prices.dagretour # is same as prices.products["Dagretour"]

# first price for "Dagretour", contains three values
dagretour_prices[0].type # vol tarief
dagretour_prices[0].train_class # "2"
dagretour_prices[0].amount # 2.40

# show prices for "Enkele reis", easy method
enkelereis_prices = prices.enkelereis
```


Copyright
---------
Copyright (c) 2013 Zilverline / Stefan Hendriks.
See [LICENSE](https://github.com/zilverline/ns-api/blob/master/LICENSE.mkd) for details.