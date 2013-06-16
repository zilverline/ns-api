Yet Another NS API
==================
A Ruby client for the NS API.

[![Build Status](https://travis-ci.org/stefanhendriks/ns-api.png?branch=master)]

Usage
=====
First, make sure you have a username and password from the NS API website.
```ruby
# get username/password from NS site
client = NSClient.new("my-username", "my-password")

# get all stations known
client.stations
```

Versions
========
Compatible with NS API V2.