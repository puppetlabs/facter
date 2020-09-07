# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'facter-ng'
  spec.version       = '4.0.36'
  spec.authors       = ['Puppet']
  spec.email         = ['team-nw@puppet.com']

  spec.summary       = 'New version of Facter'
  spec.description   = 'New version of Facter'

  spec.files = Dir['bin/facter-ng'] +
               Dir['lib/**/*.rb'] +
               Dir['lib/**/*.json'] +
               Dir['lib/**/*.conf'] +
               Dir['agent/**/*'] +
               Dir['lib/**/*.erb']

  spec.required_ruby_version = '~> 2.3'

  spec.bindir = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['agent/lib', 'lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'coveralls', '~> 0.8.23'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.74.0'
  spec.add_development_dependency 'rubycritic', '~> 4.1.0'

  spec.add_runtime_dependency 'ffi', '~> 1.9'
  spec.add_runtime_dependency 'hocon', '~> 1.3'
  spec.add_runtime_dependency 'sys-filesystem', '~> 1.3' unless Gem.win_platform?
  spec.add_runtime_dependency 'thor', ['>= 1.0.1', '< 2.0']
end
