# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'facter'
  spec.version       = '4.0.41'
  spec.authors       = ['Puppet']
  spec.email         = ['team-nw@puppet.com']

  spec.summary       = 'New version of Facter'
  spec.description   = 'New version of Facter'

  spec.files = Dir['bin/facter'] +
               Dir['lib/**/*.rb'] +
               Dir['lib/**/*.json'] +
               Dir['lib/**/*.conf'] +
               Dir['lib/**/*.erb']

  spec.required_ruby_version = '~> 2.3'
  spec.bindir = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'coveralls', '~> 0.8.23'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.81.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5.2'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.38'
  spec.add_development_dependency 'sys-filesystem', '~> 1.3'
  spec.add_development_dependency 'yard', '~> 0.9'

  spec.add_runtime_dependency 'hocon', '~> 1.3'
  spec.add_runtime_dependency 'thor', ['>= 1.0.1', '< 2.0']
end
