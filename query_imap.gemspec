# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../lib/query_imap/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'query_imap'
  spec.version       = QueryIMAP::VERSION
  spec.authors       = ['Javier Juan']
  spec.email         = ['javier@promivia.com']
  spec.summary       = %q{IMAP wrapper}
  spec.description   = %q{Enhance the way IMAP is handled}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
