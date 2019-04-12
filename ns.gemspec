# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'ns-yapi'
  gem.version       = '0.6.0'
  gem.authors       = ['Stefan Hendriks', 'Derek Kraan', 'Bob Forma']
  gem.email         = ['info@zilverline.com']
  gem.description   = 'Yet Another (Ruby) NS API client'
  gem.summary       = 'A Ruby client for the NS (Dutch Railways) API'
  gem.homepage      = 'https://github.com/zilverline/ns-api'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'addressable'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'nori'
  gem.add_dependency 'rest-client'
end
