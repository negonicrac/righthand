lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'righthand/version'

Gem::Specification.new do |gem|
  gem.name          = 'righthand'
  gem.version       = Righthand::VERSION
  gem.authors       = ['Louis T.']
  gem.email         = ['louis@negonicrac.com']
  gem.description   = 'Middleman shortcuts'
  gem.summary       = 'MIddleman shortcuts'
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency('rake')

  # HTML
  gem.add_dependency('redcarpet')
  gem.add_dependency('ruby-oembed')
end
