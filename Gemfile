# frozen_string_literal: true

source 'http://rubygems.org'

gem 'rake'
gem 'rest-client'

gemspec

group :test do
  gem 'coveralls', require: false
  gem 'mocha', require: 'mocha/api'
  gem 'pry'
  gem 'rspec'
  gem 'simplecov'
  gem 'timecop'
  gem 'webmock'
end

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
end
