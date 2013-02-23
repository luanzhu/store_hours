# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'store_hours/version'

Gem::Specification.new do |gem|
  gem.name          = "store_hours"
  gem.version       = StoreHours::VERSION
  gem.authors       = ["Yanhao Zhu"]
  gem.email         = ["yanhaozhu@gmail.com"]
  gem.description   = 'Parser for store hours'
  gem.summary       = 'Parser for store hours'
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'parslet', '~> 1.5.0'
  gem.add_dependency 'json', '~> 1.7.5'
end
