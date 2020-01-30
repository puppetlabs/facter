# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'config/config'

Gem::Specification.new do |spec|
  spec.name          = 'facter'
  spec.version       = FACTER_VERSION
  spec.authors       = ['Puppet']
  spec.email         = ['team-nw@puppet.com']

  spec.summary       = 'New version of Facter'
  spec.description   = 'New version of Facter'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # On our internal Jenkins, there is no git. As it is a clean machine, we don't need to worry about anything else.
  spec.files = if system('git --help > /dev/null')
                 `git ls-files -z`.split("\x0")
               else
                 Dir.glob('**/*')
               end

  spec.files.reject! do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'coveralls', '~> 0.8.23'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.74.0'
  spec.add_development_dependency 'rubycritic', '~> 4.1.0'
  spec.add_development_dependency 'sys-filesystem', '~> 1.3'

  spec.add_runtime_dependency 'hocon', '~> 1.3'
  spec.add_runtime_dependency 'thor', ['>= 1.0.1', '< 2.0']
end
