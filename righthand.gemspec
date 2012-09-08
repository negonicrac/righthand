# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'righthand/version'

Gem::Specification.new do |gem|
  gem.name          = "righthand"
  gem.version       = Righthand::VERSION
  gem.authors       = ["Louis T."]
  gem.email         = ["louis@negonicrac.com"]
  gem.description   = %q{Middleman shortcuts}
  gem.summary       = %q{MIddleman shortcuts}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency("rake")

  # HTML
  gem.add_dependency("redcarpet")
  gem.add_dependency("ruby-oembed")
end
