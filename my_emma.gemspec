# -*- encoding: utf-8 -*-
require File.expand_path('../lib/my_emma/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jeremy Wechsler"]
  gem.email         = ["jeremy@theaterwit.org"]
  gem.description   = %q{Interface to MyEmma API}
  gem.summary       = %q{MyEmma Interface}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "my_emma"
  gem.require_paths = ["lib"]
  gem.version       = MyEmma::VERSION
  gem.add_dependency 'json'
  gem.add_dependency 'httparty', "0.7.8"
  gem.add_dependency 'crack'
  gem.add_dependency 'activemodel'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'httplog'
  
end
