# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'config/config'

Gem::Specification.new do |spec|
  spec.name          = 'facter-ng'
  spec.version       = FACTER_VERSION
  spec.authors       = ['Bogdan Irimie']
  spec.email         = ['irimie.bogdan@puppet.com']

  spec.summary       = 'New version of Facter'
  spec.description   = 'New version of Facter'
  # spec.homepage      = " Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)

  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = `git ls-files`.split("\n").select { |file_name| file_name.match('^((?!spec).)*$') }

  spec.bindir = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'coveralls', '~> 0.8.23'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.74.0'
  spec.add_development_dependency 'rubycritic', '~> 4.1.0'

  spec.add_runtime_dependency 'bundler', '~> 2.0'
  spec.add_runtime_dependency 'hocon', '1.3.0'
  # spec.add_runtime_dependency 'thor', '~> 0.20.3'
end
