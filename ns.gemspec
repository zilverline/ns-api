# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "ns-yapi"
  gem.version       = '0.4.1'
  gem.authors       = ["Stefan Hendriks"]
  gem.email         = ["stefanhen83@gmail.com"]
  gem.description   = %q{Yet Another (Ruby) NS API client}
  gem.summary       = %q{A Ruby client for the NS (Dutch Railways) API}
  gem.homepage      = "https://github.com/stefanhendriks/ns-api"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'httpclient'
  gem.add_dependency 'nori'
  gem.add_dependency 'nokogiri'

end
