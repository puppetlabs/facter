# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'facter-ng'
  spec.version       = '4.2.2'
  spec.authors       = ['Puppet']
  spec.email         = ['team-nw@puppet.com']
  spec.homepage      = 'https://github.com/puppetlabs/facter'

  spec.summary       = 'Facter, a system inventory tool'
  spec.description   = 'You can prove anything with facts!'
  spec.license       = 'MIT'

  root_dir = File.join(__dir__, '..')
  dirs =
    Dir[File.join(root_dir, 'bin/facter-ng')] +
    Dir[File.join(root_dir, 'LICENSE')] +
    Dir[File.join(root_dir, 'lib/**/*.rb')] +
    Dir[File.join(root_dir, 'lib/**/*.json')] +
    Dir[File.join(root_dir, 'lib/**/*.conf')] +
    Dir[File.join(root_dir, 'lib/**/*.erb')]
  base = "#{root_dir}#{File::SEPARATOR}"

  spec.files = dirs.map { |path| path.sub(base, '') }

  spec.required_ruby_version = '>= 2.3', '< 4.0'

  spec.bindir = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['agent/lib', 'lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'coveralls', '~> 0.8.23'
  spec.add_development_dependency 'rake', '~> 12.3', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.74.0'
  spec.add_development_dependency 'rubycritic', '~> 4.1.0'

  spec.add_runtime_dependency 'ffi', '~> 1.9'
  spec.add_runtime_dependency 'hocon', '~> 1.3'
  spec.add_runtime_dependency 'sys-filesystem', '~> 1.3' unless Gem.win_platform?
  spec.add_runtime_dependency 'thor', ['>= 1.0.1', '< 2.0']
end
